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

class ModdingAPI {
	@:unreflective
	public static var BLACKLISTED_IMPORTS:Array<Class<Dynamic>> = [
		sys.io.File,
		sys.FileSystem
	];

	public static var MOD_FOLDER:String = 'mods';

	public static var EXT_ALIASES:Map<String, Array<String>> = [
		'lua' => ['lua', 'luac', 'luas'],
		'hx' => ['hx', 'hxc', 'hxs', 'hscript'],
		'py' => ['py', 'pyc', 'pys']
	];

	public static var STATE_PATHS = ['data/scripts/states'];

	public static function init():Void {
		trace("debug:Initializing Modding System...");
		FlxG.save.data.registeredModIds ??= [];
		FlxG.save.data.enabledModIds ??= [];
		(availableMods = [
			for (path in Paths.readFolder('mods', true)) {
				if (!Paths.fileExists('$MOD_FOLDER/$path/novamod_meta.json', true) && !Paths.fileExists('$MOD_FOLDER/$path/novamod_meta.jsonc', true)) continue;
				var meta:ModMeta = null;
				if (Paths.fileExists('$MOD_FOLDER/$path/novamod_meta.json', true)) meta = new JsonParser<ModMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent('$MOD_FOLDER/$path/novamod_meta.json')), '$MOD_FOLDER/$path/novamod_meta.json');
				if (Paths.fileExists('$MOD_FOLDER/$path/novamod_meta.jsonc', true)) meta = new JsonParser<ModMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent('$MOD_FOLDER/$path/novamod_meta.jsonc')), '$MOD_FOLDER/$path/novamod_meta.jsonc');
				if (meta == null) continue;
				meta.folder = path;
				meta.title ??= meta.folder;
				meta;
			}
		]);
		/* if (Paths.fileExists('$MOD_FOLDER/active-mods.txt', true))
			(activeModsIds = FileUtil.getFileContent('$MOD_FOLDER/active-mods.txt').split('\n').filter(id -> return getMod(id) != null)); */

		for (i in availableMods) {
			if (!FlxG.save.data.registeredModIds.contains(i.id)) {
				FlxG.save.data.registeredModIds.push(i.id);
				FlxG.save.data.enabledModIds.push(i.id);
			}
			trace('debug:Found mod "${i.title}" with id "${i.id}"');
		}

		activeModsIds = FlxG.save.data.enabledModIds;

		reloadRegistries();
	}

	public static var availableMods(default, null):Array<ModMeta> = [];
	public static var activeModsIds(default, null):Array<String> = [];

	public static function getMod(id:String):Null<ModMeta> {
		for (meta in availableMods)
			if (meta.id == id)
				return meta;
		return null;
	}

	public static function enableMod(id:String) {
		if (!activeModsIds.contains(id)) activeModsIds.push(id);
		if (!FlxG.save.data.enabledModIds.contains(id)) FlxG.save.data.enabledModIds.push(id);
	}

	public static function disableMod(id:String) {
		if (activeModsIds.contains(id)) activeModsIds.remove(id);
		if (FlxG.save.data.enabledModIds.contains(id)) FlxG.save.data.enabledModIds.remove(id);
	}

	public static function checkModEnabled(id:String):Bool
		return activeModsIds.contains(id);

	inline public static function getActiveMods():Array<ModMeta>
		return [for (id in activeModsIds) getMod(id)];


	private static var registered:Bool = false;
	public static function reloadRegistries():Void {
		trace('debug:${registered ? "Reloading" : "Initializing"} Registries...');
		registered = true;
		violet.data.noteskin.NoteSkinRegistry.registerNoteSkins();
		violet.data.level.LevelRegistry.registerLevels();
		violet.data.song.SongRegistry.registerSongs();
		violet.data.stage.StageRegistry.registerStages();
		violet.data.character.CharacterRegistry.registerCharacters();
		violet.data.chart.ChartRegistry.registerCharts();
	}
}

class ModIcon extends NovaSprite {
	override public function new(modId:String) {
		// super(violet.backend.filesystem.Cache.image('$MOD_FOLDER/$modId/novamod_icon', 'root'));
		super(Paths.file('${ModdingAPI.MOD_FOLDER}/$modId/novamod_icon', 'root', 'png'));
	}
}
#end