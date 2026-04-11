package violet.backend.utils;

import violet.backend.options.Options;

class ScoreUtil {

	public static final getSongScore = @:privateAccess Options.getSongScore;
	public static final saveSongScore = @:privateAccess Options.saveSongScore;

	public static final getSongAccuracy = @:privateAccess Options.getSongAccuracy;
	public static final saveSongAccuracy = @:privateAccess Options.saveSongAccuracy;

	public static final getLevelScore = @:privateAccess Options.getLevelScore;
	public static final saveLevelScore = @:privateAccess Options.saveLevelScore;

	public static function stringifyScore(score:Float, numberPlaces:Int = 6, addCommas:Bool = false):String {
		var scoreOut:Int = Std.int(score);
		var scoreSplit:Array<String> = '$scoreOut'.split('');
		while (scoreSplit.length < numberPlaces) scoreSplit.insert(0, '0');
		var out = scoreSplit.join('');
		if (addCommas) out = new EReg('(\\d)(?=(\\d{3})+(?!\\d))', 'g').replace(Std.string(out), '$1,');
		return out;
	}

}