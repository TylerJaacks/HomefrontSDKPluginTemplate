# MyPlugin

A [HomefrontSDK](https://github.com/TylerJaacks/HomefrontSDK) mod for the Homefront dedicated server.

## Starting from the template

1. On [HomefrontSDKPluginTemplate](https://github.com/TylerJaacks/HomefrontSDKPluginTemplate), click
   **Use this template → Create a new repository**, then clone your new repository.
2. Rename the mod (it becomes the namespace, the DLL and the folder under `Mods\`), then delete `Rename.ps1`:

   ```
   .\Rename.ps1 -Name CoolMod
   ```

3. Write your mod in the `.cs` file, and replace this section of the README with what your mod does.

## Building

**Needs:** Windows and the .NET 10 SDK; on the server machine the **32-bit (x86) .NET 10 runtime**, with
[HomefrontModLoader](https://github.com/TylerJaacks/HomefrontModLoader/releases) and
[HomefrontSDK](https://github.com/TylerJaacks/HomefrontSDK/releases) installed.

The mod builds against one of two SDKs:

- **A HomefrontSDK checkout beside this folder** (`..\HomefrontSDK`), when there is one. Nothing else is needed.
- **Otherwise the `HomefrontSDK` package** from GitHub Packages (`nuget.config`), the latest stable release. GitHub's
  NuGet feed needs a token even for public packages: set `GITHUB_TOKEN` to a personal access token (classic) with the
  `read:packages` scope. CI uses the workflow's own token.

```
dotnet build MyPlugin.slnx -c Release
```

`-p:UseLocalSdk=false` uses the package even with a checkout beside it, and `-p:HomefrontSDKVersion=0.2.0` pins a
version. The mod must run with the SDK it was built against: a binding that changed between versions fails only
when it's called (`MissingMethodException`).

### Installing

When the dedicated server is beside this folder (`..\Homefront Dedicated Server\Binaries\HomefrontSDK\HomefrontSDK.dll`
exists), every build copies the mod to `Binaries\HomefrontSDK\Mods\MyPlugin\`. Point it elsewhere with
`-p:HomefrontBinaries=<server>\Binaries`, or turn it off with `-p:InstallMod=false`.

```
<folder>\
  Homefront Dedicated Server\     the server (Binaries\HFDedicated.exe)
  HomefrontSDK\                   optional: git clone https://github.com/TylerJaacks/HomefrontSDK
  MyPlugin\                       this repository
```

Mods are loaded from bytes, so the server can keep running: build, then type `!sdk reload MyPlugin` in chat. The
mod's log is `Mods\MyPlugin\MyPlugin.log`. An exception disables the mod, with the stack trace in that log.

## Writing the mod

`MyPlugin.cs` has one `[Script]` class showing the main pieces:

| Piece | Example |
|---|---|
| Events | `OnStart`, `OnStop`, `OnTick(deltaSeconds)`, `OnMapLoaded`, `OnMapUnloading`, `OnPlayerJoined`, `OnPlayerLeft` |
| Chat commands | `[Command("myplugin")]`: `!myplugin` in chat, replies with `ctx.Reply` |
| Hooks | `[Hook("GameInfo", "Killed", After = true)]`: runs on any script function; a "before" hook returns `false` to skip the original |
| Game state | `Game.Players`, `Game.MapName`, `Game.Info`, `Game.All<T>()` |
| Logging | `Log.Write(...)`; `Directory` is the mod's folder, for its data files |

The SDK's [README](https://github.com/TylerJaacks/HomefrontSDK#writing-a-mod) documents the game classes, hooks,
native calls and the bridge for local tools.

## Releasing

`.github/workflows/build.yml` builds every push and pull request to `main` and uploads the DLL as an artifact. A
`v*` tag builds with that version and makes a GitHub Release with the `.dll` and `.pdb`, its notes naming the
HomefrontSDK release it was built against:

```
git tag v0.1.0
git push origin v0.1.0
```

Players install it as `Homefront Dedicated Server\Binaries\HomefrontSDK\Mods\MyPlugin\MyPlugin.dll`, with that
HomefrontSDK release.
