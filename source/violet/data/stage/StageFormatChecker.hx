package violet.data.stage;

@:structInit @:publicFields class VSliceStage {
	var version:String;
	var name:String;
	var props:Array<Dynamic>;
	var characters:Dynamic;
}

enum abstract StageFileFormat(String) {
	var VSLICE = 'vslice';
	var PSYCH = 'psych';
	var PSYCHLEGACY = 'psychLegacy';
	var UNKNOWN = 'unknown';
}


class StageFormatChecker {
	public static function checkFormat(parsedStageObject:Dynamic):StageFileFormat {
		var isVSlice:Bool = true;
		var isPELegacy:Bool = true;
		var isPE:Bool = true;

		for (i in Type.getInstanceFields(VSliceStage)) {
			if (!Reflect.hasField(parsedStageObject, i)) isVSlice = false;
		}
		if (isVSlice) return VSLICE;

		return UNKNOWN;
	}
}