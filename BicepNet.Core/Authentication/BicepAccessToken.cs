using System;

namespace BicepNet.Core.Authentication;

public class BicepAccessToken(string token, DateTimeOffset expiresOn)
{
    public string Token { get; set; } = token;
    public DateTimeOffset ExpiresOn { get; set; } = expiresOn;

    public override string ToString()
    {
        return Token;
    }
}
