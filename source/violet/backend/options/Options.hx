package violet.backend.options;

import flixel.util.FlxSave;

@:structInit class OptionsData {
    public var fps:Int = 60;
}

class Options {
    public static var data:OptionsData = {};
    public static var save:FlxSave;

    public static function init() {
        save = new FlxSave();
        save.bind('options', lime.app.Application.current.meta.get("file"));

        load();
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