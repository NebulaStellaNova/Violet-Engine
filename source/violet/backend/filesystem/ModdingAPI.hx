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
		'lua' => ['lua', 'luac', 'luas', 'lscript'],
		'hx' => ['hx', /* 'hxc',  */'hxs', 'hscript'],
		'py' => ['py', 'pyc', 'pys', 'pscript']
	];

	public static var STATE_PATHS = ['data/scripts/states'];

	public static function init():Void {
		#if CAN_HAXE_SCRIPT
		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!rulescript.parsers.HxParser.defaultPreprocesorValues.exists(tag))
				rulescript.parsers.HxParser.defaultPreprocesorValues.set(tag, value);
		#end
		var rootImport = violet.backend.scripting.Script.autoImports.copy();
		var jic:Map<String, Dynamic> = [
			'Float' => Float,
			'Int' => Int,
			'Bool' => Bool,
			'String' => String,
			'Array' => Array
		];
		for (key => value in jic)
			rootImport.set(key, value);
		for (key => value in rootImport)
			rulescript.RuleScript.defaultImports.get('').set(key, value);

		inline function getModulePath(name:String):String {
			// taken from rulescript test folder since what I was doing just didn't want to work
			var path:Array<String> = name.split('.');
			var pack:Array<String> = [];
			while (path[0].charAt(0) == path[0].charAt(0).toLowerCase()) pack.push(path.shift());
			var moduleName:String = null;
			if (path.length > 1) moduleName = path.shift();
			return pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0];
		}
		rulescript.types.ScriptedTypeUtil.resolveModule = (name:String) -> {
			var scriptPath:String = null;
			for (ext in ModdingAPI.EXT_ALIASES.get('hx'))
				if (Paths.fileExists(scriptPath = Paths.file('source/${getModulePath(name).replace('.', '/')}', '', ext), true))
					break;
			if (!Paths.fileExists(scriptPath, true))
				return null;
			final content = FileUtil.getFileContent(scriptPath);
			if (content.contains("scriptDisabled = true")) return null;
			final parser = new rulescript.parsers.HxParser();
			parser.mode = MODULE;
			parser.allowAll();
			return parser.parseModule(content);
		}
		#end

		trace('debug:<yellow>Initializing Modding System...');
		FlxG.save.data.registeredModIds ??= [];
		FlxG.save.data.enabledModIds ??= [];

		reloadModList();
		// FlxTimer.wait(0.01, ()->reloadModList()); // To fix vmod's not showing. I think

		activeModsIds = FlxG.save.data.enabledModIds;

		// Main.threadCallacks.addOnce(reloadRegistries);
		new HXCHandler();
		reloadRegistries();
	}

	public static function reloadModList() {
		tempFolders.resize(0);
		#if !mobile
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
		#end

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

		final foundHXC:Array<String> = checkForHXC();
		if (foundHXC.length == 0) trace('debug:<cyan>No HXC scripts found.');
		else trace(['debug:<cyan>Found HXC scripts: "<magenta>', foundHXC.join('<cyan>", "<magenta>'), '<cyan>"'].join(''));
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

			#if CAN_PYTHON_SCRIPT
			for (ext in ModdingAPI.EXT_ALIASES.get("py")) {
				if (file.endsWith('.$ext')) {
					if (!FileUtil.getFileContent(file).contains("scriptDisabled = True")) {
						pack.addScript(new violet.backend.scripting.PythonScript(file));
					}
				}
			}
			#end
		}
	}

	public static var allFolders(get, never):Array<String>;
	inline static function get_allFolders():Array<String>
		return checkFolder('') #if REDIRECT_ASSETS_FOLDER .concat(checkFolder(Paths.ASSETS_FOLDER)).concat(checkFolder(MOD_FOLDER)) #end;

	public static function checkFolder(string:String) {
		var out:Array<String> = [];
		var files = FileSystem.isDirectory(string) || string == '' ? FileSystem.readDirectory(string) : [];
		// NOTE: DOESN'T FUCKING WORK
		files = files.filter((v) -> {
			if ([Paths.ASSETS_FOLDER, MOD_FOLDER].contains(v))
				return true;
			for (mod in getActiveMods())
				if (['$MOD_FOLDER/${mod.folder}'].contains(v))
					return true;
			return false;
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
		HXCHandler.instance.hxcScripts.execute();

		return out;
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