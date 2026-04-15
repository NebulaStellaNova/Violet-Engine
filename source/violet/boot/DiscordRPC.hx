package violet.boot;

#if DISCORD_RICH_PRESENCE
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

class DiscordRPC {

	public static function init() {
		final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1481604217335713814", cpp.RawPointer.addressOf(handlers), false, null);

		Main.threadCallacks.add(() -> {
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			Discord.RunCallbacks();
		});
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>) {
		final username:String = request[0].username;
		final globalName:String = request[0].globalName;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		trace('sys:Discord: Connected to user! $username${discriminator != 0 ? '#$discriminator' : ''} ($globalName)');

		final discordPresence:DiscordRichPresence = new DiscordRichPresence();
		discordPresence.type = DiscordActivityType_Playing;
		discordPresence.details = "In the menus";
		discordPresence.largeImageKey = "https://files.catbox.moe/mp8wja.png";

		final button:DiscordButton = new DiscordButton();
		button.label = "Violet Engine Discord";
		button.url = "https://discord.gg/A3Hjgsp37r";
		discordPresence.buttons[0] = button;

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar)
		trace('sys:Discord: Disconnected ($errorCode:$message)');

	private static function onError(errorCode:Int, message:cpp.ConstCharStar)
		trace('sys:Discord: Error ($errorCode:$message)');

}
#end