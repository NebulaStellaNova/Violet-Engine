package violet.backend.utils;

class FileUtil {
	inline public static function getFileContent(path:String):String {
		return sys.io.File.getContent(path);
	}
	// inline public static function setFileContent(path:String):String {
	// 	return sys.io.File.getContent(path);
	// }
}