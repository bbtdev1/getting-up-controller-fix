# Troubleshooting

## PowerShell script will not run

If Windows blocks the installer or you see a PowerShell execution-policy error, try the following:

1. Close the current PowerShell window.
2. Open **PowerShell as Administrator** (right-click PowerShell and choose **Run as administrator**) if the installer needs permission to access your game installation.
3. First, temporarily allow scripts in the current PowerShell session only by running:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ```

4. Run the installer again from that same PowerShell window.

As a last resort, `Set-ExecutionPolicy Unrestricted` can loosen PowerShell's script restrictions more broadly. **This is not recommended as the first option**, because it weakens a security safeguard. Prefer the temporary `-Scope Process Bypass` command above, and avoid changing the policy system-wide unless you understand the security implications.

## If the installer refuses to modify the file

The installer checks the SHA-256 checksum of `binds_pc.cfg` before applying the fix.

This is intentional: the installer only modifies a configuration file matching the original version. If you have previously modified `binds_pc.cfg`, the checksum will be different and the installer will refuse to overwrite your changes.

You may see an error similar to:

```text
Unsupported binds_pc.cfg version.
```

### What should I do?

If you have manually modified your `binds_pc.cfg`:

1. Make a backup of your current file if you want to keep your custom bindings.
2. Restore the original `binds_pc.cfg` supplied by your game installation.
3. Run the installer again.
4. Reapply any personal changes after the Xbox / X-Input fix has been installed.

Alternatively, you can apply the changes manually using the patch provided in:

```text
patch/binds_pc.cfg.patch
```

**Do not replace your modified configuration with a file from this repository:** this project does not distribute the game's original configuration file.
