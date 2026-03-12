package violet.backend.scripting.events;

import violet.backend.objects.play.Strum;
import violet.backend.objects.play.Sustain;

class SustainHitEvent extends EventBase {
	public var sustain:Sustain;
	public var strum:Strum;
	public var direction:Int;
	public var noteType:String;
	public var isComputer:Bool;
	public var animCancelled:Bool = false;
	public var animationSuffix:String = null; // null for none

	public function new(sustain:Sustain, noteType:String, strum:Strum, direction:Int, isComputer:Bool) {
		this.sustain = sustain;
		this.strum = strum;
		this.direction = direction;
		this.noteType = noteType;
		this.isComputer = isComputer;
	}

	public function cancelAnim() {
		this.animCancelled = true;
	}
}