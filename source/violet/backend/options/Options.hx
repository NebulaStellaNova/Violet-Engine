package violet.backend.options;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:structInit class OptionsData {
    public var fps:Int = 60;
    public var ghostTapping:Bool = true;
    public var downscroll:Bool = false;
    public var coloredHealthBar:Bool = true;
    public var developerMode:Bool = false;
    public var mouseControls:Bool = true;
    public var forceMouseScrolling:Bool = true;
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

		'fullscreen' => ['F11', 'F11'],

		'botplay' => ['F2', 'F2'],
		'reloadGame' => ['F5', 'F5'],
		'resetState' => ['F3', 'F3'],
		'shortcutState' => ['F4', 'F4'],
		'debugDisplay' => ['F6', 'F6']
    ];
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
}