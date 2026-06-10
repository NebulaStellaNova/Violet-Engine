package violet.data.dialogue;

@:registryData('Speaker', [violet.data.dialogue.Speaker, violet.data.dialogue.SpeakerData])
class SpeakerRegistry implements violet.data.RegistryImpl {

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (file in Paths.readFolder('data/dialogue/speakers', v -> return FileUtil.isDataFile(v))) {
			final entryID = haxe.io.Path.withoutExtension(file);
			final metaPath = 'data/dialogue/speakers/$entryID';
			if (!(Paths.fileExists(Paths.json(metaPath), true) || Paths.fileExists(Paths.yaml(metaPath), true))) {
				trace('warning:<orange>Could not find $entryID, "<magenta>data/dialogue/speakers/$file<orange>", ignoring entry.');
				continue;
			}
			final parsed:Dynamic = ParseUtil.jsonOrYaml(metaPath, '', null);
			if (parsed != null) registerEntry(entryID, parsed);
			else trace('warning:<orange>Could not parse $entryID, "<magenta>data/dialogue/speakers/$file<orange>", ignoring entry.');
		}
	}

	public static function registerEntry(id:String, _data:SpeakerData):Void {
		if (entryExists(id)) {
			trace('warning:<orange>$_id with ID "<magenta>$id<orange>" is already registered, ignoring entry.');
			return;
		}
		entries.set(id, _data);
		trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
	}

	inline public static function fetchEntry(id:String):Null<SpeakerData> {
		if (!entryExists(id)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>$id<red>" doesn\'t exist.');
		return entries.get(id);
	}

}