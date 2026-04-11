package violet.states;

import violet.backend.SubStateBackend;

class ModSubState extends SubStateBackend {

	public var id:String;
	public var args:Dynamic;

	override public function new(id:String, ?args:Dynamic) {
		this.id = id;
		this.args = args;
		super();
	}

	override function getScriptName():String {
		return id;
	}

}