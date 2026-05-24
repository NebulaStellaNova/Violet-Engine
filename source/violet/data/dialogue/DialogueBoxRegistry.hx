package violet.data.dialogue;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

class DialogueBoxRegistry {

	public static var boxDatas:Map<String, DialogueBoxData> = new Map<String, DialogueBoxData>();

	public static function registerBoxes() {
		trace('debug:<yellow>Registering dialogue boxes...');

		boxDatas.clear();

		for (file in Paths.readFolder('data/dialogue/boxes', v -> return FileUtil.isDataFile(v))) {
			final fileName = haxe.io.Path.withoutExtension(file);
			final metaPath = 'data/dialogue/boxes/$fileName';
			if (!(Paths.fileExists(Paths.json(metaPath), true) || Paths.fileExists(Paths.yaml(metaPath), true))) {
				trace('warning:Could not find meta file for dialogue box with ID $file. Skipping registration.');
				continue;
			}
			var parsed:Dynamic = ParseUtil.jsonOrYaml(metaPath);
			registerBox(fileName, parsed);
		}
	}

	public static function registerBox(id:String, data:DialogueBoxData) {
		boxDatas.set(id, data);
		trace('debug:<cyan>Found and registered dialogue box with ID "<magenta>$id<cyan>"');
	}

}