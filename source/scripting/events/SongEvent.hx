package scripting.events;

class SongEvent extends EventBase {
	public var name:String = "default";
	public var type:Int = 0;
	public var parameters:Array<Dynamic>;

	public function new(name:String, ?parameters:Array<Dynamic>, type:Int = 0) {
		this.name = name;
		this.parameters = parameters ?? [];
		this.type = type;
	}
}