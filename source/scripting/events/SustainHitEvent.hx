package scripting.events;

import backend.objects.play.SustainNote;
import backend.objects.play.StrumLine;
import backend.objects.play.Strum;

class SustainHitEvent extends EventBase {
	public var sustain:SustainNote;
	public var strum:Strum;
	public var direction:Int;
	public var noteType:String;
	public var userType:UserType;
	public var animCancelled:Bool = false;

	public function new(sustain:SustainNote, noteType:String, strum:Strum, direction:Int, userType:UserType) {
		this.sustain = sustain;
		this.strum = strum;
		this.direction = direction;
		this.noteType = noteType;
		this.userType = userType;
	}

	public function cancelAnim() {
		this.animCancelled = true;
	}
}