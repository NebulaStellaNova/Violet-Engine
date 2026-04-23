package violet.data.character;

@:structInit @:publicFields class PsychEngineCharacter {
	var image:String;
	var animations:Array<Dynamic>;
}

@:structInit @:publicFields class VSliceCharacter {
	var renderType:String;
}

enum abstract CharacterFileFormat(String) {
	var VSLICE = 'vslice';
	var PSYCH = 'psych';
	var UNKNOWN = 'unknown';
}

class CharacterFormatChecker {
	public static function checkFormat(parsedStageObject:Dynamic):CharacterFileFormat {
		var isPE:Bool = true;
		var isVSlice:Bool = true;

		for (i in Type.getInstanceFields(PsychEngineCharacter)) {
			if (!Reflect.hasField(parsedStageObject, i)) isPE = false;
		}
		if (isPE) return PSYCH;

		for (i in Type.getInstanceFields(VSliceCharacter)) {
			if (!Reflect.hasField(parsedStageObject, i)) isVSlice = false;
		}
		if (isVSlice) return VSLICE;

		return UNKNOWN;
	}
}