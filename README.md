# Marc Eckō's Getting Up — Xbox / X-Input Controller Fix

Fixes the default controller bindings for **Marc Eckō's Getting Up: Contents Under Pressure** when using an Xbox 360 / X-Input controller.

## What this project contains

This project provides:

- install & uninstall scripts;
- patches for `engine/binds_pc.cfg`;
- no game files.

The repository does **not** contain the original `binds_pc.cfg` or any other files from the game.

## Requirements

- A legitimate installation of _Marc Eckō's Getting Up: Contents Under Pressure_
- An Xbox 360 or compatible X-Input controller

## Installation

1. Download this repository.
2. Close the game if it is running.
3. Run:

```powershell
.\scripts\install.ps1
```

4. Copy or enter the path to your game installation when prompted, it should look like something like this: `C:\Program Files\Steam\steamapps\common\Marc Ecko's Getting Up 2`
5. Start the game and test the controller.

The installer creates a backup of the original configuration before modifying it:

```text
engine\binds_pc.cfg.backup
```

## Troubleshooting

If the installer does not run or PowerShell displays an execution-policy error, see the [troubleshooting guide](TROUBLESHOOTING.md) for possible solutions.

## Uninstallation

To restore the original configuration:

```powershell
.\scripts\uninstall.ps1
```

The installer restores the backup created before the modification.

## Manual installation

If you prefer to modify the configuration manually, apply the changes described in:

```text
patch/binds_pc.cfg.patch
```

The patch is intended to be applied to `engine/binds_pc.cfg` in your game installation.

## Compatibility

Tested with:

- Xbox 360 wireless controller

Game version (steam build id):

- 6613048

### Want support for another controller?

If you would like to add support for another controller, feel free to [open an issue](../../issues) describing the controller and, if possible, providing its button/axis mapping.

## Disclaimer

This project is an unofficial community-made controller configuration fix.

It is not affiliated with, endorsed by, or sponsored by the copyright holders of _Marc Eckō's Getting Up: Contents Under Pressure_.

The game itself is not included in this repository.

## License

The original files belonging to _Marc Eckō's Getting Up: Contents Under Pressure_ are not part of this project and are not licensed under the Unlicense.

The Unlicense applies only to the original material contained in this repository.
