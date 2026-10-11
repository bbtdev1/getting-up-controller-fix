$ErrorActionPreference = "Stop"
$PatchFile = Join-Path $PSScriptRoot "..\patch\binds_pc.cfg.patch"
$GamePath = Read-Host "Path to your Marc Eckō's Getting Up installation"
$BindsFile = Join-Path $GamePath "engine\binds_pc.cfg"
$BackupFile = "$BindsFile.backup"
$OriginalHash = "8149406edc97290747d22cf5eeebb95c44e7940d1313a83e53be47a0c16d7e5d"
$PatchedHash  = "82d2646b306269df3754d77a66485786c81a821bcb6bc2041aa74c62f17bfefb"

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Apply-UnifiedPatch([string]$Text, [string[]]$PatchLines) {
    $lines = $Text -split "`r?`n", -1
    $out = New-Object System.Collections.Generic.List[string]
    $sourceIndex = 0
    $i = 0
    while ($i -lt $PatchLines.Count) {
        if ($PatchLines[$i] -notmatch '^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@') { $i++; continue }
        $oldStart = [int]$Matches[1]
        $oldCount = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
        while ($sourceIndex -lt ($oldStart - 1)) { $out.Add($lines[$sourceIndex]); $sourceIndex++ }
        $i++; $consumedOld = 0
        while ($i -lt $PatchLines.Count -and $PatchLines[$i] -notmatch '^@@ ') {
            $line = $PatchLines[$i]
            if ($line -eq '\ No newline at end of file') { $i++; continue }
            $prefix = $line.Substring(0,1); $body = $line.Substring(1)
            switch ($prefix) {
                ' ' { if ($sourceIndex -ge $lines.Length -or $lines[$sourceIndex] -ne $body) { throw "Patch context mismatch near source line $($sourceIndex + 1)." }; $out.Add($lines[$sourceIndex]); $sourceIndex++; $consumedOld++ }
                '-' { if ($sourceIndex -ge $lines.Length -or $lines[$sourceIndex] -ne $body) { throw "Patch removal mismatch near source line $($sourceIndex + 1)." }; $sourceIndex++; $consumedOld++ }
                '+' { $out.Add($body) }
                default { throw "Unsupported patch line: $line" }
            }
            $i++
        }
        if ($consumedOld -ne $oldCount) { throw "Patch hunk expected $oldCount old lines but consumed $consumedOld." }
    }
    while ($sourceIndex -lt $lines.Length) { $out.Add($lines[$sourceIndex]); $sourceIndex++ }
    return ($out -join "`r`n")
}

if (-not (Test-Path -LiteralPath $BindsFile -PathType Leaf)) { throw "binds_pc.cfg not found: $BindsFile" }
$currentHash = Get-Sha256 $BindsFile
if ($currentHash -eq $PatchedHash) { Write-Host "Fix already installed. Nothing to do."; exit 0 }
if ($currentHash -ne $OriginalHash) { throw "Unsupported or modified binds_pc.cfg. No changes were made." }

if (-not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { Copy-Item $BindsFile $BackupFile; Write-Host "Backup created: $BackupFile" }
else { Write-Host "Backup already exists: $BackupFile" }

$patchLines = [System.IO.File]::ReadAllLines($PatchFile, [System.Text.Encoding]::UTF8)
$originalText = [System.IO.File]::ReadAllText($BindsFile, [System.Text.Encoding]::Default)
$patchedText = Apply-UnifiedPatch $originalText $patchLines
$tempFile = "$BindsFile.tmp"
[System.IO.File]::WriteAllText($tempFile, $patchedText, [System.Text.Encoding]::Default)
if ((Get-Sha256 $tempFile) -ne $PatchedHash) { Remove-Item $tempFile -Force; throw "Patch produced an unexpected result. Original file was not modified." }
Move-Item $tempFile $BindsFile -Force
Write-Host "Xbox 360 / X-Input fix installed successfully."
Write-Host "Contents under control. Time to get up !"
