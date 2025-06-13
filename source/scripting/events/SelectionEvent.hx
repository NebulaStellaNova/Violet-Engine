package scripting.events;

class SelectionEvent extends EventBase {
	public var soundCancelled:Bool = false;

	public var selection:Int = 0;

	public function new(selection) {
		this.selection = selection;
	}

	public function cancelSound() {
		soundCancelled = true;
	}
}