package violet.backend.utils;

import lime.ui.FileDialog;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.net.FileFilter;

class FileUtil {

	public static var characterFilter(get, never):Array<String>;
	static function get_characterFilter():Array<String> {
		return ['*.yaml', '*.yml'];
	}

	inline public static function getFileContent(path:String):String {
		// trace(path);
		var data:String;
		try {
			data = #if mobile openfl.utils.Assets.exists(path) ? openfl.utils.Assets.getText(path) : #end sys.io.File.getContent(path);
		} catch (e) {
			data = "";
		}
		return data;
	}

	public static function openSaveDialog(title:String, filters:Array<String>, ?defaultPath:String, ?onSelect:String->Void) {
        var filter:Null<String> = [for (i in filters) i.replace("*.", "")].join(";");
		var fileDialog:FileDialog = new FileDialog();
		fileDialog.onSelect.add(onSelect);
		/* if (onCancel != null)
		{
			fileDialog.onCancel.add(onCancel);
		} */

		fileDialog.browse(SAVE, filter, defaultPath, title);

		// var result:Array<String> = Dialogs.openFile("Select a file please!", "Please select one or more files, so we can see if this method works", filters);
	}
	// inline public static function setFileContent(path:String):String {
	// 	return sys.io.File.getContent(path);
	// }
}