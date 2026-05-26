package violet.backend.scripting.events;

import violet.backend.objects.play.Note;

class CanHitEvent extends EventBase {

	var note:Note;

	override public function new(note:Note) {
		super();
		this.note = note;
	}
}
