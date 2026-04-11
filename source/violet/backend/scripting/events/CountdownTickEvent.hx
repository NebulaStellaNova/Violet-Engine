package violet.backend.scripting.events;

class CountdownTickEvent extends EventBase {

	public var beat:Int;
	public var countdownSprite:NovaSprite;

	override public function new(countdownSprite:NovaSprite, beat:Int) {
		super();
		this.beat = beat;
		this.countdownSprite = countdownSprite;
	}

}