package backend.objects.play;

class EventNote {
	public var name:String = "default";
	public var time:Float = 0;
	public var parameters:Array<Dynamic>;
	public var ran:Bool = false;

	public function new(name:String, time:Float, ?parameters:Array<Dynamic>) {
		this.name = name;
		this.time = time;
		this.parameters = parameters ?? [];
	}
}