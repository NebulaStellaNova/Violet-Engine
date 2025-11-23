#if MOD_SUPPORT
package violet.backend.filesystem;

import json2object.JsonParser;
import thx.semver.Version;
import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;

typedef ModContributor = {
	var name:String;
	@:default('#FFFFFF') var color:ParseColor;
	var ?role:String;
	var icon:String;
	var ?url:String;
}

typedef ModMeta = {
	@:jignored var ?folder:String;
	var id:String;
	var ?title:String;
	var ?description:String;
	var tag:String;
	var ?contributors:Array<ModContributor>;
	@:alias('mod_version') var version:Version;
}

class Modding {
	public static function init():Void {
		trace("debug:Initializing Modding System...");
		(availableMods = [
			for (path in Paths.readFolder('mods', true)) {
				if (!Paths.fileExists('mods/$path/novamod_meta.json', true)) continue;
				var meta:ModMeta = new JsonParser<ModMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent('mods/$path/novamod_meta.json')), 'mods/$path/novamod_meta.json');
				if (meta == null) continue;
				meta.folder = path;
				meta.title ??= meta.folder;
				meta;
			}
		]);
		if (Paths.fileExists('mods/active-mods.txt', true))
			(activeModsIds = FileUtil.getFileContent('mods/active-mods.txt').split('\n').filter(id -> return getMod(id) != null));

		for (i in availableMods) {
			trace('debug:Found mod "${i.title}" with id "${i.id}"');
		}
	}

	public static var availableMods(default, null):Array<ModMeta> = [];
	public static var activeModsIds(default, null):Array<String> = [];

	public static function getMod(id:String):Null<ModMeta> {
		for (meta in availableMods)
			if (meta.id == id)
				return meta;
		return null;
	}

	inline public static function getActiveMods():Array<ModMeta>
		return [for (id in activeModsIds) getMod(id)];
}

class ModIcon extends NovaSprite {
	override public function new(modId:String) {
		// super(violet.backend.filesystem.Cache.image('mods/$modId/novamod_icon', 'root'));
		super(Paths.file('mods/$modId/novamod_icon', 'root', 'png'));
	}
}
#end