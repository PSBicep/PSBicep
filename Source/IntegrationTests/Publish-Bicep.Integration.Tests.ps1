param($PUBLISH_CLIENT, $PUBLISH_SECRET, $PUBLISH_TENANT)

BeforeAll {
    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\BicepNet.PS\BicepNet.PS.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Import-Module -FullyQualifiedName "$ScriptDirectory\..\Source\Bicep.psd1" -ErrorAction Stop

    $ScriptDirectory = Split-Path -Path $PSCommandPath -Parent
    Copy-Item "$ScriptDirectory\supportFiles\*" -Destination TestDrive:\
    Write-Warning "$Env:PUBLISH_TENANT"
    #az login --service-principal -u $PUBLISH_CLIENT -p $PUBLISH_SECRET -t $PUBLISH_TENANT

    $newGuid=New-Guid
}

Describe 'Publish-Bicep' {
        
    Context 'Validate publish data' {
        It 'Should call Publish-BicepNetFile' {
            Publish-Bicep -Path 'TestDrive:\registryModule.bicep' -Target "br:bicepmodules.azurecr.io/psbicep/$($newGuid -replace '-', ''):v1"
            $myModule=Find-BicepModule -Registry 'bicepmodules.azurecr.io' | ConvertTo-Json | ConvertFrom-Json | Where-Object {$_.Endpoint -eq "psbicep/$($newGuid -replace '-', '')"}
            $myModule | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    az logout
}

