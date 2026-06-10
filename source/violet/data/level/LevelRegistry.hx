package violet.data.level;

@:registryData('Level', [violet.data.level.Level, violet.data.level.LevelData])
class LevelRegistry implements violet.data.RegistryImpl {

	inline public static function getDefaultData():LevelData {
		return {
			name: 'Untitled Level',
			titleAsset: '',
			props: [],
			visible: true,
			songs: [],
			background: '#F9CF51',
			difficulties: ['easy', 'normal', 'hard']
		}
	}

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		var hidden:Bool = false;
		for (i in ModdingAPI.getActiveMods()) if (i.hideBaseSongs) hidden = true;
		var levelFiles = Paths.readFolder('data/levels', false, hidden);
		for (levelFile in levelFiles) {
			final entryId = Path.withoutExtension(levelFile);
			var parsed = ParseUtil.jsonOrYaml('data/levels/$entryId', '', 'null');
			if (parsed != null) registerEntry(entryId, parsed);
			else trace('warning:<orange>Could not find $entryId, "<magenta>$levelFile<orange>", ignoring entry.');
		}
	}
	public static function registerEntry(id:String, _data:LevelData):Void {
		if (entryExists(id)) {
			trace('warning:<orange>$_id with ID "$id" is already registered, ignoring duplicate.');
			return;
		}
		entries.set(id, _data);
		var entry = new Level(id);
		data.push(entry);
		trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
	}

	inline public static function getVisibleEntries():Array<Level> {
		final entries = getAllEntries();
		for (entry in entries)
			if (!entry.isVisible())
				entries.remove(entry);
		return entries;
	}

}