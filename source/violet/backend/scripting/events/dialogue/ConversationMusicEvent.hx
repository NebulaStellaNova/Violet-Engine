package violet.backend.scripting.events.dialogue;

class ConversationMusicEvent extends EventBase {

	public var asset:String;
	public var fadeTime:Float;

	public function new(asset:String, fadeTime:Float) {
		super();
		this.asset = asset;
		this.fadeTime = fadeTime;
	}

}