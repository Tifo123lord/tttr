# DEADLAND: AFTER ZERO - Godot 4 Port

This is the Godot 4 project port of the existing playable slice. The checkerboard atlas is never rendered as a whole: the supplied transparent atlas was split into individual pose PNGs and the game uses AnimatedSprite2D SpriteFrames from those crops. It preserves the supplied transparent art assets and adds a real CharacterBody2D player, collision shapes, Camera2D smoothing, gravity, jump/coyote timing, acceleration/friction, state selection, melee hit checks, hitscan shooting, and a chasing CharacterBody2D zombie.

## Run
1. Install Godot 4.2+.
2. Import this folder in the Godot Project Manager.
3. Open `scenes/main.tscn` and press F6, or press F5.
4. Desktop controls: A/D or arrows move, Space/W jump, Shift run, left mouse melee, right mouse shoot.

## Android
Set an Android export preset in Project > Export. This project uses the Compatibility renderer and landscape viewport settings. An APK was not generated in the current environment because Godot and Android build tools were unavailable.

## Genuine limitation
The supplied player image is a multi-pose atlas, not a documented full animation sprite sheet. The port uses distinct atlas regions for grounded and airborne states and a physics/state architecture ready for proper SpriteFrames strips when supplied. It does not claim a full bespoke idle/walk/run/attack/death animation set from this asset alone.

## Verification status
Static validation completed: all referenced pose files exist, sprite crops retain alpha, the scene uses separate player/zombie SpriteFrames, and the floor has a real collision shape. Runtime verification could not be performed here because the Godot executable is not installed in this environment.

## Build with GitHub Actions

Create a GitHub repository, upload this project to the repository root, then open **Actions > Build Android APK > Run workflow**. When the run completes, download `deadland-after-zero-debug-apk` from the workflow artifacts. The included workflow is `.github/workflows/android.yml`.
