package violet.data.stage;


import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

import yaml.Yaml;
import yaml.Parser.ParserOptions;

using StringTools;

class StageRegistry {

    public static var stageDatas:Map<String, StageData> = new Map<String, StageData>();

    public static function registerStages() {
        stageDatas.clear();

        var stageFiles = Paths.readFolder("data/stages");
        for (file in stageFiles) {
            final filePath = Paths.file('data/stages/$file');
            final stageID = file.replace(".yaml", "");
            final options = new ParserOptions();
            options.maps = false;
            final fileData:StageData = Yaml.parse(FileUtil.getFileContent(filePath), options);

            stageDatas.set(stageID, fileData);

            trace('debug:Found and registered stage with ID "${stageID}"');
        }
    }
}