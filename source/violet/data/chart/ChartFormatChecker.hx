package violet.data.chart;

@:structInit @:publicFields class VSliceChart {
	var version:String;
	var scrollSpeed:Dynamic<Float>;
	var events:Array<Dynamic>;
	var notes:Array<Dynamic>;
}

@:structInit @:publicFields class CodenameEngineChart {
	var strumLines:Array<Dynamic>;
	var events:Array<Dynamic>;
	// var stage:String;
	var scrollSpeed:Float;
	var noteTypes:Array<String>;
}

@:structInit @:publicFields class PsychEngineChart {
	var song:String;
	var notes:Array<Dynamic>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
}

@:structInit @:publicFields class KadeEngineChart {
	var song:String;
	var notes:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
}

enum abstract ChartFileFormat(String) {
	var CODENAME = 'codename';
	var VSLICE = 'vslice';
	var PSYCH = 'psych';
	var KADE = 'kade';
	var UNKNOWN = 'unknown';
}

class ChartFormatChecker {

	public static function checkFormat(parsedChartObject:Dynamic):ChartFileFormat {
		var isVSlice:Bool = true;
		var isCNE:Bool = true;
		var isPE:Bool = true;
		var isKE:Bool = true;

		for (i in Type.getInstanceFields(PsychEngineChart)) {
			if (Reflect.hasField(parsedChartObject, 'song')) {
				if (!Reflect.hasField(Reflect.field(parsedChartObject, 'song'), i)) isPE = false;
			} else isPE = false;
		}
		if (isPE) return PSYCH;

		for (i in Type.getInstanceFields(KadeEngineChart)) {
			if (Reflect.hasField(parsedChartObject, 'song')) {
				if (!Reflect.hasField(Reflect.field(parsedChartObject, 'song'), i)) isKE = false;
			} else isKE = false;
		}
		if (isKE) return KADE;

		for (i in Type.getInstanceFields(CodenameEngineChart)) {
			if (!Reflect.hasField(parsedChartObject, i)) isCNE = false;
		}
		if (isCNE) return CODENAME;

		for (i in Type.getInstanceFields(VSliceChart)) {
			if (!Reflect.hasField(parsedChartObject, i)) isVSlice = false;
		}
		if (isVSlice) return VSLICE;

		return UNKNOWN;
	}

}