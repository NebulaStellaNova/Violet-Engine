package violet.data.dialogue;

/**
 * This is all mainly pulled from VSlice.
 */
class Conversation extends FlxSpriteGroup {

	public var scripts:ScriptPack = new ScriptPack();

	public function new() {
		/* ModdingAPI.checkForScripts('data/dialogue/boxes', id, scripts);
		if (PlayState.instance != null) {
			var songId = PlayState.song;
			if (PlayState.variation != null) songId += ':' + PlayState.variation;
			ModdingAPI.checkForScripts('songs/$songId', '${prefix == null ? '' : '$prefix-'}dialogue${suffix == null ? '' : '-$suffix'}', scripts);
		} */
	}

}