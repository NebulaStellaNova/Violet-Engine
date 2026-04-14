package violet.backend.utils;

import flixel.util.typeLimit.OneOfTwo;
import haxe.io.Path;
import lime.ui.FileDialog;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.net.FileFilter;

class FileUtil {

	public static var characterFilter(get, never):Array<String>;
	static function get_characterFilter():Array<String> {
		return ['*.yml'];
	}

	inline public static function getFileContent(path:String):String {
		// trace(path);
		var data:String;
		try {
			data = #if mobile openfl.utils.Assets.exists(path) ? openfl.utils.Assets.getText(path) : #end sys.io.File.getContent(path);
		} catch (e)
			data = '';
		return data;
	}

	public static function openSaveDialog(title:String, filters:Array<String>, ?defaultPath:String, ?onSelect:String->Void) {
		var filter:Null<String> = filters[0].replace('*.', ''); // TODO: fork lime and add multi support
		var fileDialog:FileDialog = new FileDialog();
		fileDialog.onSelect.add(onSelect);
		/* if (onCancel != null)
		{
			fileDialog.onCancel.add(onCancel);
		} */

		fileDialog.browse(SAVE, filter, defaultPath, title);

		// var result:Array<String> = Dialogs.openFile('Select a file please!', 'Please select one or more files, so we can see if this method works', filters);
	}

	public static function isDataFile(file:String):Bool {
		var isData:Bool = false;
		for (i in ['yaml', 'yml', 'json']) {
			if (Path.extension(file) == i) isData = true;
		}
		return isData;
	}

	public static function hasExt(v:String, ext:OneOfTwo<Array<String>, String>) {
		if (ext is Array) {
			var valid:Bool = false;
			for (i in cast (ext, Array<Dynamic>)) if (Path.extension(v) == i) valid = true;
			return valid;
		} else {
			return Path.extension(v) == ext;
		}
	}
	/* inline public static function setFileContent(path:String):String {
		return sys.io.File.getContent(path);
	} */

}