using Azure.Core;
using Azure.Identity;
using Bicep.Core.Configuration;
using Bicep.Core.Registry.Auth;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;

namespace PSBicep.Core.Authentication;

public class BicepTokenCredentialFactory : ITokenCredentialFactory
{
    public static string Scope { get; } = "https://management.core.windows.net/.default";
    
    internal ILogger? Logger { get; set; }
    internal TokenRequestContext TokenRequestContext { get; set; }
    internal TokenCredential? Credential { get; set; }
    internal bool InteractiveAuthentication { get; set; }

    public TokenCredential CreateChain(IEnumerable<CredentialType> credentialPrecedence, CredentialOptions? credentialOptions, Uri authorityUri)
    {
        return CreateSingle(credentialPrecedence.First(), credentialOptions, authorityUri);
    }

    public TokenCredential CreateSingle(CredentialType credentialType, CredentialOptions? credentialOptions, Uri authorityUri)
    {
        // Return the credential if already authenticated in Bicep
        if (Credential is not null)
        {
            return Credential;
        }

        throw new InvalidOperationException("Not connected to Azure. Please connect to Azure by running Connect-Bicep before running this command.");
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
        else // User did not provide a token
        {
            throw new ArgumentNullException(nameof(token), "Token must be provided for authentication.");
        }
    }

    public AccessToken? GetToken()
    {
        return Credential?.GetToken(TokenRequestContext, System.Threading.CancellationToken.None);
    }
}