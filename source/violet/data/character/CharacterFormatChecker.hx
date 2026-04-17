package violet.data.character;

@:structInit @:publicFields class PsychEngineCharacter {
	var image:String;
	var animations:Array<Dynamic>;
}

enum abstract CharacterFileFormat(String) {
	var VSLICE = 'vslice';
	var PSYCH = 'psych';
	var UNKNOWN = 'unknown';
}

class CharacterFormatChecker {
	public static function checkFormat(parsedStageObject:Dynamic):CharacterFileFormat {
		var isPE:Bool = true;

		for (i in Type.getInstanceFields(PsychEngineCharacter)) {
			if (!Reflect.hasField(parsedStageObject, i)) isPE = false;
		}
		if (isPE) return PSYCH;

		return UNKNOWN;
	}
}