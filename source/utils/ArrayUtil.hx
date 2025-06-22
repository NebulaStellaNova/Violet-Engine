package utils;

using StringTools;
class ArrayUtil {
    
    public static function getLastOf<T>(ar:Array<T>) {
        return ar[ar.length-1];
    }

    public static function getFirstOf<T>(ar:Array<T>) {
        return ar[0];
    }
    
}