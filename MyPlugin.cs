using HomefrontSDK;

namespace MyPlugin;

/// <summary>The mod's script: greets joining players, answers "!myplugin" and logs every kill. Replace with your own.</summary>
[Script(Description = "MyPlugin")]
public sealed class MyPluginScript : Script
{
    public override void OnStart() => Log.Write("MyPlugin started");

    public override void OnMapLoaded(GameInfo game) => Log.Write($"map {Game.MapName} loaded, game mode {game.ClassName}");

    public override void OnPlayerJoined(PlayerController player) => player.Tell($"[MyPlugin] welcome, {player.PlayerName}");

    [Command("myplugin", Help = "!myplugin: says hello back")]
    void HelloCommand(CommandContext ctx)
    {
        PlayerController? player = ctx.Player;  // null when a tool sent the command (hfbridge.py command)
        ctx.Reply(player == null ? $"[MyPlugin] {Game.Players.Count} player(s) on {Game.MapName}"
            : $"[MyPlugin] hi {player.PlayerName}, {Game.Players.Count} player(s) on {Game.MapName}");
    }

    [Hook("GameInfo", "Killed", After = true)]
    void OnKilled(GameInfo game, HookFrame frame) =>
        Log.Write($"{frame.Object<Controller>("Killer")?.PlayerName} killed {frame.Object<Controller>("Killed")?.PlayerName}");
}
