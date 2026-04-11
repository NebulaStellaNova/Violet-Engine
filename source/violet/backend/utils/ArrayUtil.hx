package violet.backend.utils;

using StringTools;

class ArrayUtil {

	public static function getLastOf<T>(ar:Array<T>) {
		return ar[ar.length-1];
	}
	public static function last<T>(arr:Array<T>):T {
		return getLastOf(arr);
	}

	public static function getFirstOf<T>(ar:Array<T>) {
		return ar[0];
	}
	public static function first<T>(arr:Array<T>):T {
		return getFirstOf(arr);
	}

}