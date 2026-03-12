package violet.backend.scripting.events;

class SelectionEvent extends EventBase {
	public var soundCancelled:Bool = false;

	public var selection:Int = 0;

	public function new(selection:Int) {
		this.selection = selection;
	}

	public function cancelSound():Void {
		soundCancelled = true;
	}
}