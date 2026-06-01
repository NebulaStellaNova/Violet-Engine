package violet.data.dialogue;

import violet.backend.utils.ParseUtil;

typedef ConversationData = {
	var backdrop:BackdropData;
	var ?outro:OutroData;
	var ?music:MusicData;
	var dialogue:Array<DialogueEntryData>;
}

private typedef NoData = {
	var ?type:String;
}

abstract BackdropData(Dynamic) from NoData from BackdropData_Solid {
	inline public function build(none:NoData->Void, solid:BackdropData_Solid->Void):Void {
		switch (this.type.toLowerCase()) {
			default: none(this);
			case 'solid': solid(this);
		}
	}
}
abstract OutroData(Dynamic) from NoData from OutroData_Fade {
	inline public function build(none:NoData->Void, fade:OutroData_Fade->Void):Void {
		switch (this.type.toLowerCase()) {
			default: none(this);
			case 'fade': fade(this);
		}
	}
}

typedef BackdropData_Solid = {
	> NoData,
	var color:ParseColor;
	@:default(0) var ?fadeTime:Float;
}
typedef OutroData_Fade = {
	> NoData,
	@:default(1) var ?fadeTime:Float;
}

typedef MusicData = {
	var asset:String;
	@:default(0) var ?fadeTime:Float;
	var ?pause:Bool;
}

typedef DialogueEntryData = {
	var speaker:String;
	var speakerAnim:String;
	var box:String;
	var boxAnim:String;
	var lines:ConversationText;
	var ?music:MusicData;
	@:default(1) var ?speed:Float;
}

typedef RawConversationTextPiece = {
	var ?speaker:String;
	var ?speakerAnim:String;
	var ?box:String;
	var ?boxAnim:String;
	var text:String;
	var ?music:MusicData;
	@:default(1) var ?speed:Float;
}

@:forward
abstract ConversationTextPiece(RawConversationTextPiece) from RawConversationTextPiece to RawConversationTextPiece {

	@:from inline public static function fromString(value:String):ConversationTextPiece {
		return {text: value}
	}

}
@:forward
abstract ConversationText(Array<ConversationTextPiece>) from Array<ConversationTextPiece> to Array<ConversationTextPiece> {

	@:from inline public static function fromPiece(value:ConversationTextPiece):ConversationText {
		return [value];
	}

	@:from inline public static function fromString(value:String):ConversationText {
		return fromPiece({text: value});
	}

	@:from inline public static function fromArray(value:Array<String>):ConversationText {
		return [for (text in value) {text: text}];
	}

}