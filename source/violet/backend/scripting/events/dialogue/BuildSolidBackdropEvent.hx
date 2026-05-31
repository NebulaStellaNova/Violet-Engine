package violet.backend.scripting.events.dialogue;

class BuildSolidBackdropEvent extends EventBase {

	public var color:FlxColor;
	public var fadeTime:Float;

	public function new(color:FlxColor, fadeTime:Float) {
		super();
		this.color = color;
		this.fadeTime = fadeTime;
	}

}