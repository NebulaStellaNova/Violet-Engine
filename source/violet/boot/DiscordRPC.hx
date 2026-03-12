package violet.boot;

import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;

class DiscordRPC {
    public static function init() {
        final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1481604217335713814", cpp.RawPointer.addressOf(handlers), false, null);

        Thread.create(function():Void
		{
			while (true)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end

				Discord.RunCallbacks();

				Sys.sleep(2);
			}
		});
    }

    private static function onReady(request:cpp.RawConstPointer<DiscordUser>) {
		final username:String = request[0].username;
		final globalName:String = request[0].username;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		if (discriminator != 0)
			Sys.println('Discord: Connected to user ${username}#${discriminator} ($globalName)');
		else
			Sys.println('Discord: Connected to user @${username} ($globalName)');

		final discordPresence:DiscordRichPresence = new DiscordRichPresence();
		discordPresence.type = DiscordActivityType_Playing;
		discordPresence.details = "In the menus";
		discordPresence.largeImageKey = "https://github.com/NebulaStellaNova/Violet-Engine/blob/main/art/iconOG.png?raw=true";
		// discordPresence.smallImageKey = "ptb-small";

		final button:DiscordButton = new DiscordButton();
		button.label = "Violet Engine Discord";
		button.url = "https://discord.gg/A3Hjgsp37r";
		discordPresence.buttons[0] = button;

		/* final button:DiscordButton = new DiscordButton();
		button.label = "Test 2";
		button.url = "https://discord.gg/fortnite";
		discordPresence.buttons[1] = button; */

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar)
		Sys.println('Discord: Disconnected ($errorCode:$message)');

	private static function onError(errorCode:Int, message:cpp.ConstCharStar)
		Sys.println('Discord: Error ($errorCode:$message)');
}