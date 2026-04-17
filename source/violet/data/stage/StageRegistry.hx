package violet.data.stage;

import haxe.io.Path;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class StageRegistry {

	public static var stageDatas:Map<String, StageData> = new Map<String, StageData>();

	public static function registerStages() {
		trace('debug:<yellow>Registering stages...');

		stageDatas.clear();

		for (file in Paths.readFolder('data/stages', v -> return FileUtil.isDataFile(v))) {
			if (FileUtil.hasExt(file, 'json')) {
				var parsed = ParseUtil.jsonOrYaml('data/stages/${Paths.fileName(file)}');
				var format = StageFormatChecker.checkFormat(parsed);
				if (format == VSLICE) {
					register(Paths.fileName(file), StageConverters.fromVSlice('data/stages/${Paths.fileName(file)}'));
				} else if (format == PSYCHLEGACY) {
					register(Paths.fileName(file), StageConverters.fromPsych('data/stages/${Paths.fileName(file)}'));
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