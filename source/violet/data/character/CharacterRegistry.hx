package violet.data.character;

import openfl.Assets;
import violet.backend.utils.ParseUtil;

using StringTools;

class CharacterRegistry {

	public static var characterDatas:Map<String, CharacterData> = new Map<String, CharacterData>();

	public static function registerCharacters() {
        trace('debug:<yellow>Registering characters...');
		characterDatas.clear();

		for (file in Paths.readFolder("data/characters")) {
			final charID:String = haxe.io.Path.withoutExtension(file);
			final filePath:String = 'data/characters/$charID';

			var characterData:CharacterData = null;
			if (Paths.yaml(filePath) != "") characterData = ParseUtil.yaml(filePath);
			else if (Paths.json(filePath) != "") characterData = ParseUtil.json(filePath);
			if (characterData != null) {
				characterDatas.set(charID, characterData);
				trace('debug:<cyan>Found and registered character with ID "<magenta>${charID}<cyan>"');
			}
		}
	}

}