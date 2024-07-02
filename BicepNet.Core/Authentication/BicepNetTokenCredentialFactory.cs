using Azure.Core;
using Azure.Identity;
using Bicep.Core.Configuration;
using Bicep.Core.Registry.Auth;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;

namespace BicepNet.Core.Authentication;

public class BicepNetTokenCredentialFactory : ITokenCredentialFactory
{
    public static string Scope { get; } = "https://management.core.windows.net/.default";
    
    internal ILogger? Logger { get; set; }
    internal TokenRequestContext TokenRequestContext { get; set; }
    internal TokenCredential? Credential { get; set; }
    internal bool InteractiveAuthentication { get; set; }

    public TokenCredential CreateChain(IEnumerable<CredentialType> credentialPrecedence, CredentialOptions? credentialOptions, Uri authorityUri)
    {
        // Return the credential if already authenticated in BicepNet
        if (Credential is not null)
        {
            return Credential;
        }

        // If not authenticated, ensure BicepConfig has a precedence
        if (!credentialPrecedence.Any())
        {
            throw new ArgumentException($"At least one credential type must be provided.");
        }

        // Authenticate using BicepConfig precedence
        return new ChainedTokenCredential(credentialPrecedence.Select(credentialType => CreateSingle(credentialType, null, authorityUri)).ToArray());
    }

    public TokenCredential CreateSingle(CredentialType credentialType, CredentialOptions? credentialOptions, Uri authorityUri)
    {
        Credential = credentialType switch
        {
            CredentialType.Environment => new EnvironmentCredential(new() { AuthorityHost = authorityUri }),
            CredentialType.ManagedIdentity => new ManagedIdentityCredential(options: new() { AuthorityHost = authorityUri }),
            CredentialType.VisualStudio => new VisualStudioCredential(new() { AuthorityHost = authorityUri }),
            CredentialType.VisualStudioCode => new VisualStudioCodeCredential(new() { AuthorityHost = authorityUri }),
            CredentialType.AzureCLI => new AzureCliCredential(),// AzureCLICrediential does not accept options. Azure CLI has built-in cloud profiles so AuthorityHost is not needed.
            CredentialType.AzurePowerShell => new AzurePowerShellCredential(new() { AuthorityHost = authorityUri }),
            _ => throw new NotImplementedException($"Unexpected credential type '{credentialType}'."),
        };

        return Credential;
    }

    internal void Clear()
    {
        InteractiveAuthentication = false;

        if (Credential == null)
        {
            Logger?.LogInformation("No stored credential to clear.");
            return;
        }

        Credential = null;
        Logger?.LogInformation("Cleared stored credential.");
    }

    internal void SetToken(Uri activeDirectoryAuthorityUri, string? token = null, string? tenantId = null)
    {
        // User provided a token
        if (!string.IsNullOrWhiteSpace(token))
        {
            Logger?.LogInformation("Token provided as authentication.");
            InteractiveAuthentication = false;

            // Try to parse JWT for expiry date
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwtSecurityToken = handler.ReadJwtToken(token);
                var tokenExp = jwtSecurityToken.Claims.First(claim => claim.Type.Equals("exp")).Value;
                var expDateTime = DateTimeOffset.FromUnixTimeSeconds(long.Parse(tokenExp));

                Logger?.LogInformation("Successfully parsed token, expiration date is {expDateTime}.", expDateTime);
                Credential = new ExternalTokenCredential(token, expDateTime);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Could not parse token as JWT, please ensure it is provided in the correct format!", ex);
            }
        }
        else // User did not provide a token - interactive auth
        {
            Logger?.LogInformation("Opening interactive browser for authentication...");

            // Since we cannot change the method signatures of the ITokenCredentialFactory, set properties and check them within the class
            InteractiveAuthentication = true;
            Credential = new InteractiveBrowserCredential(options: new() { AuthorityHost = activeDirectoryAuthorityUri });
            TokenRequestContext = new TokenRequestContext([Scope], tenantId: tenantId);

            // Get token immediately to trigger browser prompt, instead of waiting until the credential is used
            // The token is then stored in the Credential object, here we don't care about the return value
            GetToken();

            Logger?.LogInformation("Authentication successful.");
        }
    }

    public AccessToken? GetToken()
    {
        return Credential?.GetToken(TokenRequestContext, System.Threading.CancellationToken.None);
    }
}