$ErrorActionPreference = "Stop"
$GamePath = Read-Host "Path to your Marc Ecko's Getting Up installation"
$BindsFile = Join-Path $GamePath "engine\binds_pc.cfg"
$BackupFile = "$BindsFile.backup"
if (-not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { throw "Backup not found: $BackupFile" }
Copy-Item $BackupFile $BindsFile -Force
Write-Host "Original binds_pc.cfg restored."
