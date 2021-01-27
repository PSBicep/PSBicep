function Add-BicepDependency {
    [CmdletBinding()]
    param (
        # Path to *.dependencies.json file. If no file exists, one will be created.
        [Parameter(Mandatory)]
        [string]
        $FilePath,

        # Name of provider
        [string]
        $Type = 'RelativePath',

        # Path to bicep-file that will be added as a dependency.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSPath')]
        [string]
        $DependencyPath
    )
    
    begin {
        Write-Warning -Message "Add-BicepDependency is in preview and might experience breaking changes, use with caution."
        $ParentPath = Split-Path -Path $FilePath -Parent 
        $FilePath = Split-Path -Path $FilePath -Leaf

        # Make sure ParentPath exists and contains fullname
        if ([string]::IsNullOrEmpty($ParentPath)) {
            $ParentPath = $PWD.Path
        }
        else {
            try {
                $ParentPath = Resolve-Path -Path $ParentPath -ErrorAction 'Stop'
            }
            catch [System.Management.Automation.ItemNotFoundException] {
                $ParentPath = New-Item -Path $ParentPath -ItemType 'Directory' -ErrorAction Stop | Select-Object -ExpandProperty FullName
            }
        }
        
        Push-Location -Path $ParentPath -ErrorAction 'Stop'

        $Dependencies = @{}
        if (Test-Path -Path $FilePath) {
            $Entries = @(Get-Content -Path $FilePath -ErrorAction 'Stop' | ConvertFrom-Json)
            foreach ($entry in $Entries) {
                $ValidEntry = ConvertTo-BicepRestoreParameter -Resource $entry -ErrorAction 'Stop'
                $Dependencies[$ValidEntry.Name] = $entry
            }
        }
    }
    
    process {
        $TypeName = Get-BicepRestoreTypeName -Type $Type
        $Dependency = New-Object -TypeName $TypeName -ArgumentList $DependencyPath
        $Dependencies[$Dependency.Name] = $Dependency.ToOrderedHashTable()
    }
    
    end {
        $Dependencies.Values | ConvertTo-Json -AsArray | Out-File -Path $FilePath -Force -ErrorAction 'Stop'
        Pop-Location
    }
}