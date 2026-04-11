package violet.backend.replay;

typedef ReplayInput = {
	var time:Float;
	var key:String;
	var type:ReplayInputType;
}

typedef PlayBackInput = {
	> ReplayInput,
	var ?hit:Bool;
}

enum abstract ReplayInputType(Int) {
	var PRESS;
	var RELEASE;
}