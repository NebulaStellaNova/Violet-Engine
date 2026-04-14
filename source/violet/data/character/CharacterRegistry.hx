package violet.data.character;

import violet.data.converters.CharacterConverters;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class CharacterRegistry {

	public static var characterDatas:Map<String, CharacterData> = new Map<String, CharacterData>();

	public static function registerCharacters() {
		trace('debug:<yellow>Registering characters...');

		characterDatas.clear();

		for (file in Paths.readFolder('data/characters', v -> return FileUtil.isDataFile(v)))
			register(Paths.fileName(file), ParseUtil.jsonOrYaml('data/characters/${Paths.fileName(file)}'));

		for (file in Paths.readFolder('data/characters', v -> return FileUtil.hasExt(v, 'xml'))) {
			var convertedChar:Null<CharacterData> = CharacterConverters.fromCodenameEngine('data/characters/$file');
			if (convertedChar != null) {
				register(Paths.fileName(file), convertedChar);
			} else {
				trace('error:Codename Engine character "${Paths.fileName(file)}.xml" is invalid, not converting.');
			}
		}
	}

	public static function register(id:String, data:CharacterData) {
		characterDatas.set(id, data);
		trace('debug:<cyan>Found and registered character with ID "<magenta>$id<cyan>"');
	}

}