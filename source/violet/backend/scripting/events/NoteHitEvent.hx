package violet.backend.scripting.events;

import violet.backend.objects.play.Strum;
import violet.backend.objects.play.Note;

class NoteHitEvent extends EventBase {
	public var note:Note;
	public var strum:Strum;
	public var direction:Int;
	public var noteType:String;
	public var isComputer:Bool;
	public var animCancelled:Bool = false;
	public var animationSuffix:String = null; // null for none

	public function new(note:Note, noteType:String, strum:Strum, direction:Int, isComputer:Bool) {
		this.note = note;
		this.strum = strum;
		this.direction = direction;
		this.noteType = noteType;
		this.isComputer = isComputer;
	}

	public function cancelAnim() {
		this.animCancelled = true;
	}
}