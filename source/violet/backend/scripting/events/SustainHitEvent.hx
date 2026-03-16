package violet.backend.scripting.events;

import violet.backend.objects.play.Strum;
import violet.backend.objects.play.Sustain;

class SustainHitEvent extends EventBase {
	public final sustain:Sustain;
	public final strum:Strum;

	public var direction(get, set):Int;
	function get_direction():Int return sustain.id;
	function set_direction(value:Int):Int return sustain.id = value;

	public var noteType(get, set):String;
	function get_noteType():String return sustain.noteType;
	function set_noteType(value:String):String return sustain.noteType = value;

	public var isComputer(get, never):Bool;
	function get_isComputer():Bool return sustain.parent.isComputer;

	public var playStrumAnim:Bool = true;

	public var animCancelled:Bool = false;
	public var animationSuffix:String = null; // null for none

	public function new(sustain:Sustain) {
        super();
		this.sustain = sustain;
		this.strum = sustain.parentStrum;
	}

	public function cancelAnim():Void {
		this.animCancelled = true;
	}
	public function stopStrumAnim():Void {
		this.playStrumAnim = false;
	}
}