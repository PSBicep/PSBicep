class BicepDiagnosticEntry {
    [string] $LocalPath
    [int[]] $Position
    [BicepDiagnosticLevel] $Level
    [string] $Code
    [string] $Message

    BicepDiagnosticEntry ([object]$Entry) {
        if($Entry.pstypenames[0] -ne 'BicepNet.Core.DiagnosticEntry') {
            throw "Requires type 'BicepNet.Core.DiagnosticEntry'"
        }
        $this.LocalPath = $Entry.LocalPath
        $this.Position = $Entry.Position[0], $Entry.Position[1]
        $this.Level = $Entry.Level.ToString()
        $this.Code = $Entry.Code
        $this.Message = $Entry.Message
    }
}