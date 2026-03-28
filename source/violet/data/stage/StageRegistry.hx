package violet.data.stage;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class StageRegistry {

    public static var stageDatas:Map<String, StageData> = new Map<String, StageData>();

    public static function registerStages() {
        trace('debug:<yellow>Registering stages...');

        stageDatas.clear();

        for (file in Paths.readFolder("data/stages")) {
            if (!FileUtil.isDataFile(file)) continue;
            final stageID = Paths.fileName(file);
            stageDatas.set(stageID, ParseUtil.jsonOrYaml('data/stages/$stageID'));
            trace('debug:<cyan>Found and registered stage with ID "<magenta>${stageID}<cyan>"');
        }
    }
}
