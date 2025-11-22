package violet.backend.utils;

using StringTools;
class NovaUtils {

    public static function playMusic(path:String, volume:Float = 1) {
        FlxG.sound.playMusic(Paths.music(path.split(".")[0] + "/" + Paths.getFileName(path) + path.split(".").pop()), volume);
    }

}