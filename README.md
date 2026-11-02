# Epic Duck - Nintendo 3DS Homebrew

Native Nintendo 3DS homebrew project using devkitARM, libctru, citro3d and citro2d.

## Build Requirements
- A computer with [devkitPro](https://devkitpro.org/) installed
- The 3DS development packages (`3ds-dev`)
- Run the build from a devkitPro MSYS2 / 3DS development shell

## Local Build
```bash
make
```

This creates:
- `EpicDuck.3dsx` (homebrew launcher executable)
- `EpicDuck.elf` (debuggable ELF)
- `EpicDuck.cia` (installable CIA, if makerom + build.rsf succeed)

## GitHub Actions
Every push to `main` automatically builds the project using the official `devkitpro/devkitarm` Docker image and uploads the `.3dsx` / `.cia` / `.elf` as artifacts.

Go to the **Actions** tab of this repo to download the latest build.

## Copy to your 3DS
Put the `.3dsx` in `/3ds/EpicDuck/` on your SD card and launch it with the Homebrew Launcher.
Or install the `.cia` with FBI / Title Manager.

## Controls
- D-pad / Circle Pad: move
- A: jump
- B: dash / boss attack
- START: pause / exit

## Notes
This is a native C homebrew adaptation of Epic Duck's platform-game idea.
The `source/main.c` currently contains a **placeholder**. Replace it with your real game code.

Icon is a tiny dummy PNG — replace `icon.png` with a proper 48x48 (or larger) icon for a real SMDH.
