package violet.data.stage;

import haxe.io.Path;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

@:registryData('Stage', [violet.data.stage.Stage, violet.data.stage.StageData])
class StageRegistry implements violet.data.RegistryImpl {

	public static function registerEntries():Void {
		trace('debug:<yellow>Registering ${id}s...');

		clearEntries();

		for (file in Paths.readFolder('data/stages', v -> return FileUtil.isDataFile(v))) {
			final fileName = Paths.fileName(file);
			if (FileUtil.hasExt(file, 'json')) {
				var parsed = ParseUtil.json('data/stages/$fileName');
				var format = StageFormatChecker.checkFormat(parsed);
				switch (format) {
					case VSLICE: registerEntry(fileName, StageConverters.fromVSlice('data/stages/$fileName'));
					case PSYCHLEGACY: registerEntry(fileName, StageConverters.fromPsych('data/stages/$fileName'));
					default: registerEntry(fileName, parsed);
				}
			} else registerEntry(fileName, ParseUtil.yaml('data/stages/$fileName'));
		}

		for (file in Paths.readFolder('data/stages', v -> return FileUtil.hasExt(v, 'xml'))) {
			final fileName = Paths.fileName(file);
			var convertedStage:Null<StageData> = StageConverters.fromCodenameEngine('data/stages/$file');
			if (convertedStage != null) registerEntry(fileName, convertedStage);
			else trace('error:Codename Engine stage "$fileName.xml" is invalid, not converting.');
		}
	}

	public static function registerEntry(id:String, _data:StageData):Void {
		entries.set(id, _data);
		trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
	}

	inline public static function fetchEntry(id:String):Null<StageData> {
		if (!entryExists(id)) // we love inlining :3
			trace('debug:<red>Character entry "<yellow>$id<red>" doesn\'t exist.');
		return entries.get(id);
	}

}