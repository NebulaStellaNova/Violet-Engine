#if MOD_SUPPORT
package violet.backend.filesystem;

import json2object.JsonParser;
// import thx.semver.Version;

typedef ModContributor = {
	var name:String;
	var color:String;
	var ?role:String;
	var icon:String;
	var ?url:String;
}

typedef ModMeta = {
	@:jignored var ?folder:String;
	var id:String;
	var title:String;
	var ?description:String;
	var tag:String;
	var ?contributors:Array<ModContributor>;
	// @:alias('mod_version') var version:Version;
}

class Modding {
	public static function init():Void {
		/* availableMods = [
			for (Paths.readFolder('mods', true))
				new JsonParser<RawModMeta>();
		]; */
		trace('?');
	}

	public static var availableMods(default, null):Array<ModMeta> = [];
	public static var activeModsIds(default, null):Array<String> = [];
}
#end