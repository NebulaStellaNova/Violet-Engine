package violet.data.dialogue;

typedef ConversationData = {
	var backdrop:BackdropData;
	var ?outro:OutroData;
	var ?music:MusicData;
	var dialogue:Array<DialogueEntryData>;
}

enum BackdropData {
	SOLID(data:BackdropData_Solid);
}

typedef BackdropData_Solid = {
	var type:String;
	var color:ParseColor;
	@:default(0) var ?fadeTime:Float;
}

enum OutroData {
	NONE(data:OutroData_None);
	FADE(data:OutroData_Fade);
}

typedef OutroData_None = {
	var type:String;
}

typedef OutroData_Fade = {
	var type:String;
	@:default(1) var ?fadeTime:Float;
}

typedef MusicData = {
	var asset:String;
	@:default(0) var ?fadeTime:Float;
	@:default(false) var ?looped:Bool;
}

typedef DialogueEntryData = {
	var speaker:String;
	var speakerAnimation:String;
	var box:String;
	var boxAnimation:String;
	var text:Array<String>;
	@:default(1) var ?speed:Float;
}