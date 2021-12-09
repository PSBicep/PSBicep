function Uninstall-BicepCLI {
    [CmdLetBinding()]
    param (
        [switch]$Force
    )

    if (-not $Script:ModuleVersionChecked) {
        TestModuleVersion
    }
    
    if (-not $IsWindows) {
        Write-Error -Message "This cmdlet is only supported for Windows systems. `
To uninstall Bicep on your system see instructions on https://github.com/Azure/bicep"
        Write-Host "`nList the available module cmdlets by running 'Get-Help -Name Bicep'`n"
        break
    }

    if (TestBicep) {
        # Test if we are running as administrators.
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $IsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $IsAdmin -and -not $Force) {
            Write-Error 'Some Bicep parts might not be properly uninstalled unless you run elevated. Use the -Force switch to try anyway. Any Bicep version installed by Azure CLI to %USERPROFILE%\.Azure\bin will not be uninstalled.'
        }
        if (-not $IsAdmin -and $Force) {
            Write-Host 'You are not running elevated. We may not be able to remove all parts.'
        }
        if ($IsAdmin -or $Force) {
            $UninstallerFileName = 'unins000.exe'
            $BicepExeName = 'bicep.exe'
            $BicepInstalls = $env:Path -split ';' | Where-Object { $_ -like "*\.bicep" -or $_ -like "*\Bicep CLI" }

            foreach ($Install in $BicepInstalls) {
                $FileContents = Get-ChildItem $Install
                if (($UninstallerFileName -in $FileContents.Name) -and ($BicepExeName -in $FileContents.Name)) {
                    # Bicep is installed using installer. Try using it to uninstall
                    $UninstallerPath = ($FileContents | Where-Object -Property Name -eq $UninstallerFileName).FullName
                    & $UninstallerPath /VERYSILENT
                    do {
                        $UninstallProcess = Get-Process -Name $UninstallerFileName.Replace('.exe', '') -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 1
                    } until ($null -eq $UninstallProcess)
                }
                else {
                    # Bicep is running in standalone exe mode. Remove manualy
                    $ExePath = Join-path -Path $Install -ChildPath $BicepExeName
                    if (Test-Path $ExePath) {
                        Remove-Item $ExePath
                    }
                }
            }

            # verify that no bicep install is still reachable
            $Removed = TestBicep
            if ($Removed) {
                Throw "Unknown version of Bicep is still installed."
            }
            else {
                Write-Host "Successfully removed bicep."
            }

        }
    }
    else {
        Write-Error "Bicep CLI is not installed on this device, nothing to uninstall."
    }
}