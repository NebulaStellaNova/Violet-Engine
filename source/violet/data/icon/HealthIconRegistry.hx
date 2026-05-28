package violet.data.icon;

import violet.backend.utils.ParseUtil;

@:registryData('HealthIcon', [violet.data.icon.HealthIcon, violet.data.icon.HealthIconData])
class HealthIconRegistry implements violet.data.RegistryImpl {

	public static function registerEntries() {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (file in Paths.readFolder('data/icons')) {
			final entryId:String = haxe.io.Path.withoutExtension(file);
			final filePath:String = 'data/icons/$entryId';
			var healthIconData:HealthIconData = null;
			if (Paths.yaml(filePath) != '') healthIconData = ParseUtil.yaml(filePath);
			else if (Paths.json(filePath) != '') healthIconData = ParseUtil.json(filePath);
			if (healthIconData != null) registerEntry(entryId, healthIconData);
			else trace('warning:<orange>Could not find $entryId, "<magenta>$file<orange>", ignoring entry.');
		}
	}

	public static function registerEntry(id:String, _data:HealthIconData):Void {
		entries.set(id, _data);
		trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
	}

	inline public static function fetchEntry(id:String):Null<HealthIconData> {
		if (!entryExists(id)) // we love inlining :3
			trace('debug:<red>$_id entry "<yellow>$id<red>" doesn\'t exist.');
		return entries.get(id);
	}

}