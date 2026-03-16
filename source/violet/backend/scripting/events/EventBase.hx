package violet.backend.scripting.events;

class EventBase {
	public var cancelled:Bool = false;

	public function new() {}

	public function cancel():Void {
		cancelled = true;
	}
}