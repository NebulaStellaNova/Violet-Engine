package violet.backend.scripting.events;

class EventBase {
	public var cancelled:Bool = false;

	public function cancel() {
		cancelled = true;
	}
}