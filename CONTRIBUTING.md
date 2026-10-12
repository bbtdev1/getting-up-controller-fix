# Contributing

## Adding a new controller

To add support for a new controller, create a dedicated unified-diff patch in `patch/` (for example, `ps5-dualsense.patch`) based on the original `binds_pc.cfg`, then add a corresponding profile to the `$Controllers` list in `scripts/install.ps1`.

The profile should define a unique `Id`, a display `Name`, the path to its patch, the SHA-256 hash of the original configuration, and the SHA-256 hash of the patched result.

The patch must be based on the same supported original configuration and must produce exactly the expected patched file so that the installer can verify it safely.

Do not distribute the game's original configuration file; only commit the patch, scripts, documentation, and other original project material. Finally, test a clean installation, switching from another supported profile, and uninstalling before opening a pull request.

### Example profile

```powershell
$xbox360 = [PSCustomObject]@{
        Id           = "xbox360"
        Name         = "Xbox 360 / X-Input"
        Patch        = Join-Path $ScriptDir "..\patches\xbox360.patch"
        OriginalHash = "8149406edc97290747d22cf5eeebb95c44e7940d1313a83e53be47a0c16d7e5d"
        PatchedHash  = "..."
    }
}
```
