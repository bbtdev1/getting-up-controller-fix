$ErrorActionPreference = "Stop"

# Marc Ecko's Getting Up - Controller Fix Installer
# The installer only modifies binds_pc.cfg when its exact contents are known.

# Script folder (with a fallback if $PSScriptRoot is empty)
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$xbox360 = [PSCustomObject]@{
        Id           = "xbox360"
        Name         = "Xbox 360 / X-Input"
        Patch        = Join-Path $ScriptDir "..\patches\xbox360.patch"
        OriginalHash = "8149406edc97290747d22cf5eeebb95c44e7940d1313a83e53be47a0c16d7e5d"
        PatchedHash  = "82d2646b306269df3754d77a66485786c81a821bcb6bc2041aa74c62f17bfefb"
    }

$Controllers = @(
    $xbox360
)

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Apply-UnifiedPatch([string]$Text, [string[]]$PatchLines) {
    # Minimal unified-diff applier. It deliberately verifies every context/removal line.
    $lines = $Text -split "`r?`n", -1
    $out = New-Object System.Collections.Generic.List[string]
    $sourceIndex = 0
    $i = 0

    while ($i -lt $PatchLines.Count) {
        if ($PatchLines[$i] -notmatch '^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@') {
            $i++
            continue
        }

        $oldStart = [int]$Matches[1]
        $oldCount = if ($Matches[2]) { [int]$Matches[2] } else { 1 }

        while ($sourceIndex -lt ($oldStart - 1)) {
            $out.Add($lines[$sourceIndex])
            $sourceIndex++
        }

        $i++
        $consumedOld = 0

        while ($i -lt $PatchLines.Count -and $PatchLines[$i] -notmatch '^@@ ') {
            $line = $PatchLines[$i]

            if ($line -eq '\\ No newline at end of file') {
                $i++
                continue
            }

            if ($line.Length -eq 0) {
                throw "Invalid empty patch line near source line $($sourceIndex + 1)."
            }

            $prefix = $line.Substring(0, 1)
            $body   = $line.Substring(1)

            switch ($prefix) {
                ' ' {
                    if ($sourceIndex -ge $lines.Length -or $lines[$sourceIndex] -ne $body) {
                        throw "Patch context mismatch near source line $($sourceIndex + 1)."
                    }
                    $out.Add($lines[$sourceIndex])
                    $sourceIndex++
                    $consumedOld++
                }
                '-' {
                    if ($sourceIndex -ge $lines.Length -or $lines[$sourceIndex] -ne $body) {
                        throw "Patch removal mismatch near source line $($sourceIndex + 1)."
                    }
                    $sourceIndex++
                    $consumedOld++
                }
                '+' {
                    $out.Add($body)
                }
                default {
                    throw "Unsupported patch line: $line"
                }
            }

            $i++
        }

        if ($consumedOld -ne $oldCount) {
            throw "Patch hunk expected $oldCount old lines but consumed $consumedOld."
        }
    }

    while ($sourceIndex -lt $lines.Length) {
        $out.Add($lines[$sourceIndex])
        $sourceIndex++
    }

    return ($out -join "`r`n")
}

function Get-ControllerByHash([string]$Hash) {
    foreach ($controller in $Controllers) {
        if ($controller.PatchedHash -eq $Hash) {
            return $controller
        }
    }
    return $null
}

function Show-Menu([string]$CurrentName) {
    Write-Host ""
    Write-Host "Marc Ecko's Getting Up - Controller Fix"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Current configuration: $CurrentName"
    Write-Host ""
    Write-Host "Select the controller you want to use:"
    Write-Host ""

    for ($index = 0; $index -lt $Controllers.Count; $index++) {
        $number = $index + 1
        $controller = $Controllers[$index]
        $available = Test-Path -LiteralPath $controller.Patch -PathType Leaf
        $suffix = if ($available) { "" } else { " (patch not available)" }
        Write-Host "  [$number] $($controller.Name)$suffix"
    }

    Write-Host "  [Q] Quit"
    Write-Host ""
}

do {
    $GamePath = (Read-Host "Path to your Marc Ecko's Getting Up installation").Trim().Trim('"')
} while ([string]::IsNullOrWhiteSpace($GamePath))

$BindsFile = Join-Path $GamePath "engine\binds_pc.cfg"
$BackupFile = "$BindsFile.backup"

if (-not (Test-Path -LiteralPath $BindsFile -PathType Leaf)) {
    throw "binds_pc.cfg not found: $BindsFile"
}

$currentHash = Get-Sha256 $BindsFile
$currentController = Get-ControllerByHash $currentHash

# All controller profiles currently use the same original file as their base.
$OriginalHash = $Controllers[0].OriginalHash

if ($currentHash -eq $OriginalHash) {
    $currentName = "Original"
}
elseif ($null -ne $currentController) {
    $currentName = $currentController.Name
}
else {
    throw "Unsupported or modified binds_pc.cfg. No changes were made."
}

Show-Menu $currentName
$selection = (Read-Host "Selection").Trim()

if ($selection -match '^[Qq]$') {
    Write-Host "No changes made."
    exit 0
}

if ($selection -notmatch '^\d+$') {
    throw "Invalid selection."
}

$index = [int]$selection - 1
if ($index -lt 0 -or $index -ge $Controllers.Count) {
    throw "Invalid selection."
}

$target = $Controllers[$index]

if ($null -eq $target -or [string]::IsNullOrWhiteSpace($target.Patch)) {
    throw "No valid controller profile selected."
}

if (-not (Test-Path -LiteralPath $target.Patch -PathType Leaf)) {
    throw "The patch for '$($target.Name)' is not available yet."
}

if ($currentController -and $currentController.Id -eq $target.Id) {
    Write-Host ""
    Write-Host "$($target.Name) fix is already installed. Nothing to do."
    exit 0
}

# If switching from another controller profile, restore the known original first.
if ($currentController) {
    if (-not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) {
        throw "A controller fix is installed, but the original backup was not found. No changes were made."
    }

    if ((Get-Sha256 $BackupFile) -ne $OriginalHash) {
        throw "The backup does not match the supported original configuration. No changes were made."
    }

    Copy-Item -LiteralPath $BackupFile -Destination $BindsFile -Force
    $currentHash = Get-Sha256 $BindsFile

    if ($currentHash -ne $OriginalHash) {
        throw "Failed to restore the original configuration. No patch was applied."
    }
}
else {
    # First installation: preserve the user's original game file.
    if (Test-Path -LiteralPath $BackupFile -PathType Leaf) {
        if ((Get-Sha256 $BackupFile) -ne $OriginalHash) {
            throw "An existing backup was found, but it does not match the supported original configuration. No changes were made."
        }
    }
    else {
        Copy-Item -LiteralPath $BindsFile -Destination $BackupFile
        Write-Host "Backup created: $BackupFile"
    }
}

Write-Host ""
Write-Host "Installing $($target.Name) fix..."

$patchLines = [System.IO.File]::ReadAllLines($target.Patch, [System.Text.Encoding]::UTF8)
$originalText = [System.IO.File]::ReadAllText($BindsFile, [System.Text.Encoding]::Default)
$patchedText = Apply-UnifiedPatch $originalText $patchLines

$tempFile = "$BindsFile.tmp"

try {
    [System.IO.File]::WriteAllText($tempFile, $patchedText, [System.Text.Encoding]::Default)

    if ((Get-Sha256 $tempFile) -ne $target.PatchedHash) {
        throw "Patch produced an unexpected result. The original file was not modified."
    }

    Move-Item -LiteralPath $tempFile -Destination $BindsFile -Force
}
finally {
    if (Test-Path -LiteralPath $tempFile) {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "$($target.Name) fix installed successfully."
Write-Host "Contents Under Control. Time to Get Up!"
