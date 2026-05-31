package violet.backend.scripting.events;

class PlayAnimationEvent extends EventBase {

	public var name:String;
	public var forced:Bool;
	public var reversed:Bool;
	public var frame:Int;

	public function new(name:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super();
		this.name = name;
		this.forced = forced;
		this.reversed = reversed;
		this.frame = frame;
	}

}