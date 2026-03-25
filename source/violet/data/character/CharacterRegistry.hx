package violet.data.character;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class CharacterRegistry {

	public static var characterDatas:Map<String, CharacterData> = new Map<String, CharacterData>();

	public static function registerCharacters() {
        trace('debug:<yellow>Registering characters...');

		characterDatas.clear();

		for (file in Paths.readFolder("data/characters")) {
			if (!FileUtil.isDataFile(file)) continue;
            final charID = Paths.fileName(file);
			characterDatas.set(charID, ParseUtil.jsonOrYaml('data/characters/$charID'));
			trace('debug:<cyan>Found and registered character with ID "<magenta>${charID}<cyan>"');
		}
	}

}