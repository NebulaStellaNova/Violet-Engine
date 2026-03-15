package violet.backend.utils;

class FileUtil {
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
	// inline public static function setFileContent(path:String):String {
	// 	return sys.io.File.getContent(path);
	// }
}