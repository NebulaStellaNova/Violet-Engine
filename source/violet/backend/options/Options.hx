package violet.backend.options;

import flixel.util.FlxSave;

@:structInit class OptionsData {
    public var fps:Int = 60;
    public var ghostTapping:Bool = true;
    public var downscroll:Bool = false;
    public var coloredHealthBar:Bool = true;
    public var developerMode:Bool = false;
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
    }
}