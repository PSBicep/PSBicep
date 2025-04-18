using System;
using Azure.Core;
using PSBicep.Core.Authentication;
using PSBicep.Core.Models;

namespace PSBicep.Core.Services;

public class BicepAuthentication
{
    private readonly BicepTokenCredentialFactory tokenCredentialFactory;

    public BicepAuthentication(BicepTokenCredentialFactory tokenCredentialFactory)
    {
        this.tokenCredentialFactory = tokenCredentialFactory;
    }

    public void SetAuthentication(string? token = null, string? tenantId = null) =>
        tokenCredentialFactory.SetToken(new Uri("inmemory:///main.bicp"), token, tenantId);

    public AccessToken? GetAccessToken()
    {
        return tokenCredentialFactory.GetToken();
    }
}