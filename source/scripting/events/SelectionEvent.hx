package scripting.events;

class SelectionEvent {
    public var cancelled:Bool = false;
    public var soundCancelled:Bool = false;

    public var selection:Int = 0;

    public function new(selection) {
        this.selection = selection;
    }

    public function cancel() {
        cancelled = true;
    }

    public function cancelSound() {
        soundCancelled = true;
    }
}