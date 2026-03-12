package violet.backend.scripting.events;

class SongEvent extends EventBase {
	public var name:String = "default";
	public var parameters:Array<Dynamic>;

	public var params(get, set):Array<Dynamic>;
	function get_params() return parameters;
	function set_params(value:Array<Dynamic>) return parameters = value;

	public function new(name:String, ?parameters:Array<Dynamic>) {
		this.name = name;
		this.parameters = parameters ?? [];
	}
}