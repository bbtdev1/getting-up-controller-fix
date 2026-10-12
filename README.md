# Marc Eckō's Getting Up — Controller Fix

Fixes the default controller bindings for **Marc Eckō's Getting Up: Contents Under Pressure** by applying controller-specific patches to `engine/binds_pc.cfg`.

I loved this game when I was younger, and I couldn't just let people who want to revisit it be disappointed by modern controller compatibility issues and give up on playing it because it doesn't work out of the box on Steam with newer controllers.

My goal was to make it as easy as possible for anyone to enjoy the game again with a simple patch, without having to install a mod or having to modify files manually.

## What this project contains

This project provides:

- install & uninstall scripts;
- controller-specific patches for `engine/binds_pc.cfg`;
- no game files.

The repository does **not** contain the original `binds_pc.cfg` or any other files from the game.

## Requirements

- A legitimate installation of _Marc Eckō's Getting Up: Contents Under Pressure_
- A supported controller with an available patch in this repository.

## Installation

1. Download this repository.
2. Close the game if it is running.
3. Run:

```powershell
.\scripts\install.ps1
```

4. Copy or enter the path to your game installation when prompted, it should look like something like this: `C:\Program Files\Steam\steamapps\common\Marc Ecko's Getting Up 2`
5. Select the controller profile you want to install.
6. Start the game and test the controller.

The installer creates a backup of the original configuration before modifying it:

```text
engine\binds_pc.cfg.backup
```

## Supported controllers

The installer is designed to support multiple controller profiles. Each profile has its own patch and expected SHA-256 checksum.

Currently available:

- Xbox 360 / X-Input

## Switching controllers

The installer does not stack controller patches.

When switching from one supported controller profile to another, it first restores the verified original configuration from the backup and then applies the selected controller patch.

This prevents one controller patch from being applied on top of another.

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

If you would like support for another controller, feel free to [open an issue](../../issues) describing the controller and, if possible, providing its button and axis mapping.

Pull requests adding support for additional controllers are also welcome, see the [contributing guide](CONTRIBUTING.md).

## Disclaimer

This project is an unofficial community-made controller configuration fix.

It is not affiliated with, endorsed by, or sponsored by the copyright holders of _Marc Eckō's Getting Up: Contents Under Pressure_.

The game itself is not included in this repository.

## License

The original files belonging to _Marc Eckō's Getting Up: Contents Under Pressure_ are not part of this project and are not licensed under the Unlicense.

The Unlicense applies only to the original material contained in this repository.

## Credits

- LinoleumKnife86 for the xbox 360 bindings available on this [steam guide](https://steamcommunity.com/sharedfiles/filedetails/?id=237505853).
