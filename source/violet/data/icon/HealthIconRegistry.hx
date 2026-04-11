package violet.data.icon;

import openfl.Assets;
import violet.backend.utils.ParseUtil;

using StringTools;

class HealthIconRegistry {

	public static var healthIconDatas:Map<String, HealthIconData> = new Map<String, HealthIconData>();

	public static function registerIcons() {
		trace('debug:<yellow>Registering health icons...');
		healthIconDatas.clear();

		for (file in Paths.readFolder('data/icons')) {
			final iconID:String = haxe.io.Path.withoutExtension(file);
			final filePath:String = 'data/icons/$iconID';
			var healthIconData:HealthIconData = null;
			if (Paths.yaml(filePath) != '') healthIconData = ParseUtil.yaml(filePath);
			else if (Paths.json(filePath) != '') healthIconData = ParseUtil.json(filePath);
			if (healthIconData != null) {
				healthIconDatas.set(iconID, healthIconData);
				trace('debug:<cyan>Found and registered health icon with ID "<magenta>${iconID}<cyan>"');
			}
		}
	}

}