package violet.data;

typedef Judgement = {
	var splash:Bool;
	var score:Float;
	var rating:String;
}

class Scoring {

	public static var enableKiller:Bool = false;

	//        TODO: Add other input windows        \\
	// -- Default is P-Bot 1 input from V-Slice -- \\

	public static var killerWindow:Float = 12.5;
	public static var sickWindow:Float = 45;
	public static var goodWindow:Float = 90;
	public static var badWindow:Float = 135;
	public static var shitWindow:Float = 160;

	public static var scoringSlope:Float = 0.080; // Thank you v-slice <3
	public static var minScore:Float = 9;
	public static var maxScore:Float = 500;
	public static var missScore:Float = -100;
	public static var missThreshold:Float = 160; // YEESH
	public static var scoringOffset:Float = 54.99; // Used for fancy math :P
	public static var perfectThreshold:Float = 5;

	public static function judgeNoteHit(ms:Float):Judgement {
		var msAbs = Math.abs(ms);
		var judgement:Judgement = { splash: false, score: 0, rating: 'miss' };

		if (enableKiller && msAbs < killerWindow) judgement.rating = 'killer';
		else if (msAbs < sickWindow) judgement.rating = 'sick';
		else if (msAbs < goodWindow) judgement.rating = 'good';
		else if (msAbs < badWindow) judgement.rating = 'bad';
		else /* if (msAbs < shitWindow) */ judgement.rating = 'shit';
		// else judgement.rating = 'miss';

		if (judgement.rating == 'sick' || judgement.rating == 'killer')
			judgement.splash = true;

		if (msAbs > missThreshold) judgement.score = missScore;
		else if (msAbs < perfectThreshold) judgement.score = maxScore;
		else {
			var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-scoringSlope * (msAbs - scoringOffset))));
			judgement.score = Std.int(maxScore * factor + minScore);
		}

		return judgement;
	}

}