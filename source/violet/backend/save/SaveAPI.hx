package violet.backend.save;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.DynamicAccess;

class SaveAPI {

	public static var saveLocation:String = "NebulaStellaNova/Violet-Engine";

	public static var data:Map<String, DynamicAccess<Dynamic>> = [];

	public static function flush() {
		for (i in data.keys()) {
			var path = '${getAppDataPath()}/$saveLocation/$i.vsave';
			File.saveContent(path, encrypt(Json.stringify(data.get(i))));
		}
	}

	@:unreflective static function encrypt(data:String):String {
		var string = data.split('');
		for (i=>letter in string) {
			string[i] = shiftString(letter, i);
		}
		return string.join('');
	}

	@:unreflective static function decrypt(data:String):String {
		var string = data.split('');
		for (i=>letter in string) {
			string[i] = shiftString(letter, -i);
		}
		return string.join('');
	}

	public static function initSlot(slot:String) {
		setSlot(slot, null);
	}

	public static function setSlot(slot:String, value:Dynamic) {
		data.set(slot, value);
	}

	public static function getAppDataPath():String {
		var it:String = switch (Sys.systemName()) {
			case "Windows":
				Sys.getEnv("APPDATA");
			case "Mac":
				Sys.getEnv("HOME") + "/Library/Application Support";
			default: // Linux
				var xdg = Sys.getEnv("XDG_CONFIG_HOME");
				if (xdg != null && xdg != "") xdg else Sys.getEnv("HOME") + "/.config";
		}
		return it.replace('\\', '/');
	}

	public static function shiftString(text:String, shiftAmount:Int):String {
        var shiftedText = new StringBuf();
        shiftAmount = shiftAmount % 95;
        if (shiftAmount < 0) {
            shiftAmount += 95;
        }

        for (i in 0...text.length) {
            var charCode = text.charCodeAt(i);
            if (charCode >= 32 && charCode <= 126) {
                var newCode = ((charCode - 32 + shiftAmount) % 95) + 32;
                shiftedText.addChar(newCode);
            }
            else {
                shiftedText.addChar(charCode);
            }
        }

        return shiftedText.toString();
    }

	public static function load() {
		var loco = "";
		for (i in saveLocation.split('/')) {
			loco = [loco, i].join('/');
			if (!FileSystem.exists('${getAppDataPath()}/$loco')) {
				FileSystem.createDirectory('${getAppDataPath()}/$loco');
			}
		}

		for (i in FileSystem.readDirectory('${getAppDataPath()}/$saveLocation')) {
			if (Path.extension(i) == 'vsave') {
				var slotID = Path.withoutExtension(i);
				setSlot(slotID, decrypt(File.getContent('${getAppDataPath()}/$saveLocation/$i')));
			}
		}

		trace(data);
	}
}