using Azure.Core;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace BicepNet.Core.Authentication;

public class ExternalTokenCredential(string token, DateTimeOffset expiresOn) : TokenCredential
{
    private readonly string token = token;
    private readonly DateTimeOffset expiresOn = expiresOn;

    public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken)
    {
        return new AccessToken(token, expiresOn);
    }

    public override ValueTask<AccessToken> GetTokenAsync(TokenRequestContext requestContext, CancellationToken cancellationToken)
    {
        return new ValueTask<AccessToken>(new AccessToken(token, expiresOn));
    }
}