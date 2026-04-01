package violet.backend.filesystem;
import haxe.zip.Entry;
import haxe.io.BytesInput;
import haxe.io.Path;
import sys.FileSystem;
import openfl.Assets;
import violet.backend.utils.NovaUtils;
import violet.states.InitialState;
#if MOD_SUPPORT

import thx.semver.Version;
import violet.backend.scripting.ScriptPack;
import violet.backend.utils.FileUtil;
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

	var mod_version:String; // Version is being weird /shrug
}

class ModdingAPI {
	@:unreflective public static var BLACKLISTED_IMPORTS:Array<Class<Dynamic>> = [
		sys.io.File,
		sys.FileSystem
	];

	@:unreflective public static var tempFolders:Array<String> = [];

	public static var availableMods(default, null):Array<ModMeta> = [];
	public static var activeModsIds(default, null):Array<String> = [];

	public static #if release inline #end final MOD_FOLDER:String = #if REDIRECT_ASSETS_FOLDER "../../../../mods" #else "mods" #end;
	public static var API_VERSION:Version = "0.0.0";

	public static var EXT_ALIASES:Map<String, Array<String>> = [
		'lua' => ['lua', 'luac', 'luas'],
		'hx' => ['hx', /* 'hxc',  */'hxs', 'hscript'],
		'py' => ['py', 'pyc', 'pys']
	];

	public static var STATE_PATHS = ['data/scripts/states'];

	public static function init():Void {
		trace('debug:<yellow>Initializing Modding System...');
		FlxG.save.data.registeredModIds ??= [];
		FlxG.save.data.enabledModIds ??= [];

		reloadModList();
		FlxTimer.wait(0.01, ()->reloadModList()); // To fix vmod's not showing. I think

		activeModsIds = FlxG.save.data.enabledModIds;

		// Main.threadCallacks.addOnce(reloadRegistries);
		reloadRegistries();
		new HXCHandler();
		// trace(checkForHXC().join('\n'));
	}

	public static function reloadModList() {
		tempFolders = [];
		for (path in Paths.readFolder(MOD_FOLDER, true)) {
			if (path.endsWith('.vmod') && !FileSystem.isDirectory('$MOD_FOLDER/$path')) {
				var folderName:String = path.replace('.vmod', "");
				trace('debug:Found violet mod with id "$folderName"');
				var modPath:String = '$MOD_FOLDER/.$folderName';
				tempFolders.push(modPath);
				if (FileSystem.exists(modPath)) continue;
				FileSystem.createDirectory(modPath);
      			Sys.command("attrib +h " + modPath);

				#if debug var startTime = Sys.time(); #end
				violet.backend.utils.ZipUtil.extractZip('$MOD_FOLDER/$path', modPath);
				#if debug var delta = (Sys.time() - startTime) * 1000;
				trace('debug:VMod extraction took ${Math.round(delta*100)/100} milliseconds'); #end
			}
		}

		@:bypassAccessor availableMods = [
			for (path in Paths.readFolder(MOD_FOLDER, true)) {
				var meta:ModMeta = ParseUtil.json('$MOD_FOLDER/$path/novamod_meta', 'root');
				if (meta == null) meta = ParseUtil.yaml('$MOD_FOLDER/$path/novamod_meta', 'root');
				if (meta == null) continue;

				// null check all properties and set defaults
				meta.folder = path;
				meta.title ??= meta.folder;
				for (contributor in meta.contributors)
					contributor.color ??= FlxColor.WHITE;
				meta;
			}
		];

		for (i in availableMods) {
			if (!FlxG.save.data.registeredModIds.contains(i.id)) {
				FlxG.save.data.registeredModIds.push(i.id);
				FlxG.save.data.enabledModIds.push(i.id);
			}
			trace('debug:<cyan>Found mod "<magenta>${i.title}<cyan>" with id "<magenta>${i.id}<cyan>"');
		}
	}

	public static function getMod(id:String):ModMeta {
		for (meta in availableMods) {
			// trace(meta);
			if ('${meta.id}' == id)
				return meta;
		}
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
		return [for (id in activeModsIds) getMod(id)].filter((meta)->{return meta.id != "null";});


	private static var registered:Bool = false;
	public static function reloadRegistries():Void {
		trace('debug:<yellow>${registered ? "Reloading" : "Initializing"} Registries...');
		NovaUtils.CURRENT_MUSIC = null;
		registered = true;
		violet.data.notestyles.NoteStyleRegistry.registerNoteStyles();
		InitialState.loadingPercent += 1/7;
		violet.data.level.LevelRegistry.registerLevels();
		InitialState.loadingPercent += 1/7;
		violet.data.song.SongRegistry.registerSongs();
		InitialState.loadingPercent += 1/7;
		violet.data.stage.StageRegistry.registerStages();
		InitialState.loadingPercent += 1/7;
		violet.data.icon.HealthIconRegistry.registerIcons();
		InitialState.loadingPercent += 1/7;
		violet.data.character.CharacterRegistry.registerCharacters();
		InitialState.loadingPercent += 1/7;
		violet.data.chart.ChartRegistry.registerCharts();
		InitialState.loadingPercent += 1/7;
	}

	#if SCRIPT_SUPPORT

	public static function checkForScripts(path:String, ?fileName:String = null, pack:ScriptPack) {
		var scriptList = [for (file in Paths.readFolder('${Paths.ASSETS_FOLDER}/$path', true)) '${Paths.ASSETS_FOLDER}/$path/$file' ];
		for (mod in getActiveMods()) {
			scriptList = scriptList.concat([for (file in Paths.readFolder('$MOD_FOLDER/${mod.folder}/$path', true)) '$MOD_FOLDER/${mod.folder}/$path/$file' ]);
		}
		var finalList:Array<String> = [];
		if (fileName != null) {
			for (i in scriptList) {
				if (Paths.getFileName(i, true) == fileName) finalList.push(i);
			}
			scriptList = finalList;
		}
		for (file in scriptList) {

			#if CAN_HAXE_SCRIPT
			for (ext in ModdingAPI.EXT_ALIASES.get("hx")) {
				if (file.endsWith('.$ext')) {
					if (!FileUtil.getFileContent(file).contains("scriptDisabled = true")) {
						pack.addScript(new violet.backend.scripting.FunkinScript(file));
					}
				}
			}
			#end

			#if CAN_LUA_SCRIPT
			for (ext in ModdingAPI.EXT_ALIASES.get("lua")) {
				if (file.endsWith('.$ext')) {
					if (!FileUtil.getFileContent(file).contains("scriptDisabled = true")) {
						pack.addScript(new violet.backend.scripting.LuaScript(file));
					}
				}
			}
			#end
		}
	}

	public static var allFolders(get, never):Array<String>;
	static function get_allFolders() return checkFolder('');

	public static function checkFolder(string:String) {
		var out:Array<String> = [];
		var files = FileSystem.isDirectory(string) || string == '' ? FileSystem.readDirectory(string) : [];
		if (string == '') files = files.filter((v) -> {
			return [Paths.ASSETS_FOLDER, MOD_FOLDER].contains(v);
		});
		for (i in files) {
			var path = string == '' ? i : [string, i].join('/');
			if (FileSystem.isDirectory(path)) {
				out.push(path);
				out = out.concat(checkFolder(path));
			}
		}
		return out;
	}

	public static function checkForHXC():Array<String> {
		HXCHandler.instance.clear();
		var out:Array<String> = [];

		for (i in allFolders) {
			var files = (FileSystem.readDirectory(i) ?? []).filter((f)->return f.endsWith('.hxc'));
			for (f in files) out.push([i, f].join('/'));
		}

		for (i in out) {
			if (FileUtil.getFileContent(i).contains("scriptDisabled = true")) continue;
			HXCHandler.instance.addScript(i);
		}

		return out;
	}

	public static function checkForScript(string:String, pack:ScriptPack) {

		#if CAN_LUA_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("lua")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.LuaScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("hx")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.FunkinScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("py")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.PythonScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end
	}
	#end

	@:unreflective public static function powerDown() {
		for (i in tempFolders) {
			if (FileSystem.exists(i)) deleteDirectory(i);
		}
	}

	@:unreflective static function deleteDirectory(path) {
		var subObjects = FileSystem.readDirectory(path);
		for (i in subObjects) {
			if (!StringTools.contains(i, ".")) {
				deleteDirectory(path + "/" + i);
			} else {
				FileSystem.deleteFile(path + "/" + i);
			}
		}
		FileSystem.deleteDirectory(path);
	}
}

class ModIcon extends NovaSprite {
	override public function new(modId:String) {
		var image = Paths.image('${ModdingAPI.MOD_FOLDER}/$modId/novamod_icon', 'root');
		if (!Paths.fileExists(image, true)) {
			image = Paths.image('${ModdingAPI.MOD_FOLDER}/example/novamod_icon', 'root');
		}
		super(image);
	}
}
#end