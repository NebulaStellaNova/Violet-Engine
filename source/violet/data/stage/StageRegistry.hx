package violet.data.stage;

import violet.data.converters.StageFormatChecker;
import haxe.io.Path;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.data.converters.StageConverters;

class StageRegistry {

	public static var stageDatas:Map<String, StageData> = new Map<String, StageData>();

	public static function registerStages() {
		trace('debug:<yellow>Registering stages...');

		stageDatas.clear();

		for (file in Paths.readFolder('data/stages', v -> return FileUtil.isDataFile(v))) {
			if (FileUtil.hasExt(file, 'json')) {
				var parsed = ParseUtil.jsonOrYaml('data/stages/${Paths.fileName(file)}');
				if (StageFormatChecker.checkFormat(parsed) == VSLICE) {
					var converted = StageConverters.fromVSlice('data/stages/${Paths.fileName(file)}');
					trace(Paths.fileName(file));
					register(Paths.fileName(file), converted);
				} else {
					register(Paths.fileName(file), parsed);
				}
			} else {
				register(Paths.fileName(file), ParseUtil.jsonOrYaml('data/stages/${Paths.fileName(file)}'));
			}
		}

		for (file in Paths.readFolder('data/stages', v -> return FileUtil.hasExt(v, 'xml'))) {
			var convertedStage:Null<StageData> = StageConverters.fromCodenameEngine('data/stages/$file');
			if (convertedStage != null) {
				register(Paths.fileName(file), convertedStage);
			} else {
				trace('error:Codename Engine stage "${Paths.fileName(file)}.xml" is invalid, not converting.');
			}
		}
	}

	public static function register(stageID:String, data:StageData) {
		stageDatas.set(stageID, data);
		trace('debug:<cyan>Found and registered stage with ID "<magenta>${stageID}<cyan>"');
	}

}