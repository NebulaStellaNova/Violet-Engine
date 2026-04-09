package violet.backend.options;

import flixel.util.FlxSave;

@:structInit class OptionsData {
    public var fps:Int = 60;
    public var ghostTapping:Bool = true;
    public var downscroll:Bool = false;
    public var coloredHealthBar:Bool = true;
    public var developerMode:Bool = false;
    public var mouseControls:Bool = #if mobile false #else true #end;
    public var forceMouseScrolling:Bool = true;
    public var debugDisplayOnStart:Bool = false;
    public var personalScrollSpeed:Float = 0;
    public var disableScoreLerping:Bool = false;
    public var playAsOpponent:Bool = false;
    public var gpuCaching:Bool = false;
    public var controls:Map<String, Array<String>> = [
        'note_left' => ['A', 'LEFT'],
        'note_down' => ['S', 'DOWN'],
        'note_up' => ['W', 'UP'],
        'note_right' => ['D', 'RIGHT'],

        'ui_left' => ['A', 'LEFT'],
		'ui_down' => ['S', 'DOWN'],
		'ui_up' => ['W', 'UP'],
		'ui_right' => ['D', 'RIGHT'],

		'accept' => ['ENTER', 'SPACE'],
		'back' => ['BACKSPACE', 'ESCAPE'],
		'pause' => ['ENTER', 'ESCAPE'],
		'reset' => ['R', 'DELETE'],

		'volume_up' => ['PLUS', 'NUMPADPLUS'],
		'volume_down' => ['MINUS', 'NUMPADMINUS'],
		'volume_mute' => ['ZERO', 'NUMPADZERO'],

        // getAnyJustPressed([NONE]) will return true if nothing is pressed

		'fullscreen' => ['F11', 'F11'],

		'botplay' => ['F1', 'F1'],
		'console' => ['F2', 'F2'],
		'resetState' => ['F3', 'F3'],
		'shortcutState' => ['F4', 'F4'],
		'reloadGame' => ['F5', 'F5'],
		'debugDisplay' => ['F6', 'F6']
    ];

    public var savedScores:Map<String, Int> = [];
    public var savedAccuracies:Map<String, Int> = [];

    public var savedLevelScores:Map<String, Int> = [];
    public var savedLevelAccuracies:Map<String, Int> = [];

}

class Options {
    public static var data:OptionsData = {};
    public static var save:FlxSave;

    public static function init() {
        save = new FlxSave();
        save.bind('options', lime.app.Application.current.meta.get("file"));

        load();
    }

    public static function set(what:String, value:Dynamic) {
        if (Reflect.fields(data).contains(what)) {
            Reflect.setProperty(data, what, value);
        } else {
            trace('warning:Could not find option data for value $what');
        }
    }

    public static function get(what:String):Dynamic {
        return  Reflect.getProperty(data, what) ?? null;
    }

    /**
     * Loads save data to the struct.
     */
    private static function load() {
        for (field in Reflect.fields(save.data)) {
            var value = Reflect.getProperty(save.data, field);

            if (value == null) {
                value = Reflect.getProperty(data, field);
                Reflect.setProperty(save.data, field, value);
                continue;
            }

            Reflect.setProperty(data, field, value);
        }
        updateControls();
    }

    /**
     * Sets your save data to whatever's in the struct.
     * Kind of like flushing a toilet.
     */
    public static function flush() {
        for (field in Reflect.fields(data)) {
            var value = Reflect.getProperty(data, field);
            Reflect.setProperty(save.data, field, value);
        }

        save.flush();
        updateControls();
    }

    public static function updateControls() {
        for (key in data.controls.keys()) {
            Controls.bindMap.set(key, [ for (i in data.controls.get(key)) FlxKey.fromString(i) ]);
        }
    }

    private static function getSongScore(id:String, difficulty:String, ?variation:String) {
        var saveID:String = [ id, variation != '' && variation != null ? ':$variation' : '', ':$difficulty' ].join('');
        return data.savedScores.get(saveID) ?? 0;
    }

    private static function saveSongScore(id:String, difficulty:String, ?variation:String, score:Int, force:Bool = false) {
        if (score > getSongScore(id, difficulty, variation) || force) {
            var saveID:String = [ id, variation != '' && variation != null ? ':$variation' : '', ':$difficulty' ].join('');
            data.savedScores.set(saveID, score);
        }
        flush();
    }

    private static function getLevelScore(id:String, difficulty:String) {
        var saveID:String = [ id, ':$difficulty' ].join('');
        return data.savedLevelScores.get(saveID) ?? 0;
    }

    private static function saveLevelScore(id:String, difficulty:String, score:Int, force:Bool = false) {
        if (score > getLevelScore(id, difficulty) || force) {
            var saveID:String = [ id, ':$difficulty' ].join('');
            data.savedLevelScores.set(saveID, score);
        }
        flush();
    }
}