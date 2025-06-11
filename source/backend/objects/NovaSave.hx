package backend.objects;

import flixel.util.FlxSave;

class NovaSave {
    public static var saveData:FlxSave;

    public static function init():Void {
        saveData = new FlxSave();
        saveData.bind("nova-engine", "NebulaStellaNova");

        if(saveData.data.theData == null) {
            saveData.data.theData = [
                "initialized" => true
            ];
        }
    } 

    public static function set(variable:String, value:Dynamic):Void {
        saveData.data.theData.set(variable, value);
    }

    public static function setIfNull(variable:String, value:Dynamic):Void {
        if (!saveData.data.theData.exists(variable)) {
            set(variable, value);
        }
    }

    public static function get(variable:String):Null<Dynamic> {
        if (saveData.data.theData.exists(variable)) {
            return saveData.data.theData.get(variable);
        } else {
            return null;
        }
    }
}