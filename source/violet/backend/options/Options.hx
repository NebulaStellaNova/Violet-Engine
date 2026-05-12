package violet.backend.options;

import haxe.DynamicAccess;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import lime.app.Application;
import violet.data.song.Song;
import violet.data.song.Variation;

@:structInit class OptionsData {

	public var fps:Int = 60;
	public var ghostTapping:Bool = true;
	public var downscroll:Bool = false;
	public var disableHoldJitter:Bool = false;
	public var coloredHealthBar:Bool = true;
	public var developerMode:Bool = #if debug true #else false #end;
	public var mouseControls:Bool = #if mobile false #else true #end;
	public var forceMouseScrolling:Bool = true;
	public var debugDisplayOnStart:Bool = #if debug true #else false #end;
	public var personalScrollSpeed:Float = 0;
	public var disableScoreLerping:Bool = false;
	public var kadePopups:Bool = false;
	public var playMissSound:Bool = true;
	public var botplayFlashingText:Bool = true;
	public var playAsOpponent:Bool = false;
	public var gpuCaching:Bool = false;
	public var antialiasTextures:Bool = true;
	public var forceMiddleScroll:Bool = false;
	public var vsync:Bool = #if linux false #else true #end;
	public var controls:Map<String, Array<FlxKey>> = [
		'note_left' => ['A', 'LEFT'],
		'note_down' => ['S', 'DOWN'],
		'note_up' => ['W', 'UP'],
		'note_right' => ['D', 'RIGHT'],

		'ui_left' => ['A', 'LEFT'],
		'ui_down' => ['S', 'DOWN'],
		'ui_up' => ['W', 'UP'],
		'ui_right' => ['D', 'RIGHT'],

		'ui_left_tabs' => ['Q', 'COMMA'],
		'ui_right_tabs' => ['E', 'PERIOD'],
		'favorite' => ['F', 'NONE'],

		'accept' => ['ENTER', 'SPACE'],
		'back' => ['BACKSPACE', 'ESCAPE'],
		'pause' => ['ENTER', 'ESCAPE'],
		'reset' => ['R', 'DELETE'],

		'volume_up' => ['PLUS', 'NUMPADPLUS'],
		'volume_down' => ['MINUS', 'NUMPADMINUS'],
		'volume_mute' => ['ZERO', 'NUMPADZERO'],

		'fullscreen' => ['F11', 'NONE'],

		'botplay' => ['F1', 'NONE'],
		'console' => ['F2', 'NONE'],
		'resetState' => ['F3', 'NONE'],
		'shortcutState' => ['F4', 'NONE'],
		'reloadGame' => ['F5', 'NONE'],
		'debugDisplay' => ['F6', 'NONE']
	];

	public var savedScores:Map<String, Int> = [];
	public var savedAccuracies:Map<String, Float> = [];

	public var savedLevelScores:Map<String, Int> = [];

	// modID<songID:variant, Bool>
	public var favoritedSongs:Map<String, Map<String, Bool>> = [];

	public var modOptions:Dynamic = {}

	// -- Lane Underlays -- \\
	public var laneUnderlay:Bool = false;
	public var laneGrow:Float = 20; // px
	public var underlayOpacity:Float = 25; // %

	public var fancyLaneUnderlay:Bool = false;
	public var laneFlashIntensity:Float = 100; // %
	public var underlayOnlyForPlayer:Bool = true;

	public var enableNoteSplashes:Bool = true;
	public var enableHoldCovers:Bool = true;

	public var hideScore:Bool = false;
	public var hideAccuracy:Bool = false;

	public var accuracyCalculation:AccuracyBase = RATING; // 0 = Rating, 1 = Millisecond
}

enum abstract AccuracyBase(Int) {
	var RATING;
	var MILLISECOND;
}

@:forward
abstract DynamicMap<T>(DynamicAccess<T>) from DynamicAccess<T> to DynamicAccess<T> from Dynamic<T> to Dynamic<T> from Dynamic to Dynamic {
	public function exists(key:String):Bool
		return this.exists(key) || Type.getClass(this) == null ? false : Type.getInstanceFields(Type.getClass(this)).contains(key);
}

class Options {

	public static var data:OptionsData = {}
	public static var save:FlxSave;

	public static function init() {
		save = new FlxSave();
		save.bind('options', Application.current.meta.get("file"), (data, error) -> {
			trace([data, error]);
			return data;
		});
		@:privateAccess save.checkStatus();

		load();

		Application.current.window.onClose.add(() -> {
			flush();
			save.close();
		});
	}

	public static function set(what:String, value:Dynamic) {
		final saveData:DynamicMap<Dynamic> = data;
		if (saveData.exists(what)) {
			saveData.set(what, value);
			setterCallback(what);
		} else {
			trace('warning:Could not find option data for value $what');
		}
	}

	public static function setterCallback(what:String) {
		switch (what) {
			case 'fps', 'vsync':
				var newFps = data.vsync ? Application.current.window.displayMode.refreshRate : data.fps;
				if (data.vsync && data.fps == Application.current.window.displayMode.refreshRate) return;
				if (data.fps > FlxG.drawFramerate) {
					FlxG.updateFramerate = newFps;
					FlxG.drawFramerate = newFps;
				} else {
					FlxG.drawFramerate = newFps;
					FlxG.updateFramerate = newFps;
				}
		}
	}

	public static function get(what:String):Dynamic {
		final saveData:DynamicMap<Dynamic> = data;
		return saveData.get(what);
	}

	inline static function toDyMap<T>(dy:DynamicMap<T>):String {
		return '{' + [for (field => value in dy) '\n\t$field: $value'].join(',') + '\n}';
	}

	/**
	 * Loads save data to the struct.
	 */
	private static function load() {
		trace(save.data);
		@:privateAccess save.data ??= {} // jic
		final flxSave:DynamicMap<Dynamic> = save.data;
		final saveData:DynamicMap<Dynamic> = data;
		trace('pre load');
		trace('Flixel: ' + toDyMap(flxSave));
		trace('Engine: ' + toDyMap(saveData));

		for (field => value in flxSave) {
			if (!saveData.exists(field)) continue;
			if (value == null) {
				flxSave.set(field, saveData.get(field));
				continue;
			}
			if (saveData.exists(field))
				saveData.set(field, value);
		}
		trace('post load');
		trace('Flixel: ' + toDyMap(flxSave));
		trace('Engine: ' + toDyMap(saveData));

		updateControls();
	}

	/**
	 * Sets your save data to whatever's in the struct.
	 * Kind of like flushing a toilet.
	 */
	public static function flush() {
		final flxSave:DynamicMap<Dynamic> = save.data;
		final saveData:DynamicMap<Dynamic> = data;

		trace('pre flush');
		trace('Flixel: ' + toDyMap(flxSave));
		trace('Engine: ' + toDyMap(saveData));
		for (field => value in saveData)
			flxSave.set(field, value);
		trace('post flush');
		trace('Flixel: ' + toDyMap(flxSave));
		trace('Engine: ' + toDyMap(saveData));

		save.flush();
		updateControls();

		trace('sys:Successfully flushed save data.');
	}

	public static function updateControls() {
		for (key in data.controls.keys())
			Controls.bindMap.set(key, [for (i in data.controls.get(key)) i]);
	}

	private static function getSongAccuracy(id:String, difficulty:String, ?variation:Variation) {
		return data.savedAccuracies.get(Song.setupId(id, difficulty, variation)) ?? 0;
	}

	private static function saveSongAccuracy(id:String, difficulty:String, ?variation:Variation, accuracy:Float, force:Bool = false) {
		if (accuracy > getSongAccuracy(id, difficulty, variation) || force)
			data.savedAccuracies.set(Song.setupId(id, difficulty, variation), accuracy);
		flush();
	}

	private static function getSongScore(id:String, difficulty:String, ?variation:Variation) {
		return data.savedScores.get(Song.setupId(id, difficulty, variation)) ?? 0;
	}

	private static function saveSongScore(id:String, difficulty:String, ?variation:Variation, score:Int, force:Bool = false) {
		if (score > getSongScore(id, difficulty, variation) || force) {
			data.savedScores.set(Song.setupId(id, difficulty, variation), score);
		}
		flush();
	}

	private static function getLevelScore(id:String, difficulty:String) {
		return data.savedLevelScores.get(Song.setupId(id, difficulty)) ?? 0;
	}

	private static function saveLevelScore(id:String, difficulty:String, score:Int, force:Bool = false) {
		if (score > getLevelScore(id, difficulty) || force) {
			data.savedLevelScores.set(Song.setupId(id, difficulty), score);
		}
		flush();
	}

	public static function getSongFavoritedStatus(modID:String, songID:String, ?variant:Variation):Bool {
		if (!data.favoritedSongs.exists(modID)) return false;
		return data.favoritedSongs.get(modID).get(Song.setupId(songID, null, variant)) ?? false;
	}
	public static function setSongFavoritedStatus(modID:String, songID:String, ?variant:Variation, state:Bool):Void {
		if (!data.favoritedSongs.exists(modID))
			data.favoritedSongs.set(modID, []);
		data.favoritedSongs.get(modID).set(Song.setupId(songID, null, variant), state);
		flush();
	}
	inline public static function toggleSongFavoritedStatus(modID:String, songID:String, ?variant:Variation):Bool {
		setSongFavoritedStatus(modID, songID, variant, getSongFavoritedStatus(modID, songID, variant));
		return getSongFavoritedStatus(modID, songID, variant);
	}

}
