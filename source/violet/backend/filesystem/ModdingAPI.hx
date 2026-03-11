#if MOD_SUPPORT
package violet.backend.filesystem;

import thx.semver.Version;
import violet.backend.utils.ParseUtil;

typedef ModContributor = {
	var name:String;
	var color:ParseColor;
	var ?role:String;
	var icon:String;
	var ?url:String;
}

typedef ModMeta = {
	var ?folder:String;
	var id:String;
	var title:String;
	var description:String;
	var tags:Array<String>; // For mod sorting
	var contributors:Array<ModContributor>;

	// Not enforced like V-Slice, it is literally only for backwards compatibility.
	var ?api_version:Version;

	var mod_version:Version;
}

class ModdingAPI {
	@:unreflective public static var BLACKLISTED_IMPORTS:Array<Class<Dynamic>> = [
		sys.io.File,
		sys.FileSystem
	];

	public static var MOD_FOLDER:String = 'mods';
	public static var API_VERSION:Version = "0.0.0";

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
				var meta:ModMeta = ParseUtil.json('$MOD_FOLDER/$path/novamod_meta', 'root');
				if (meta == null) continue;

				// null check all properties and set defaults
				meta.folder = path;
				meta.title ??= meta.folder;
				for (contributor in meta.contributors)
					contributor.color ??= FlxColor.WHITE;
				meta;
			}
		]);

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

	public static function getMod(id:String):ModMeta {
		for (meta in availableMods)
			if (meta.id == id)
				return meta;
		return {id: "null", title: "Unknown Mod", description: "You don't have any mod metadata!", folder: null, mod_version: "0.0.0", api_version: API_VERSION, tags: [], contributors: []};
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
		super(Paths.image('${ModdingAPI.MOD_FOLDER}/$modId/novamod_icon', 'root'));
	}
}
#end