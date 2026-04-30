package violet.backend.scripting.events;

import violet.data.Constants;
import violet.states.PlayState;
import violet.backend.objects.play.Note;
import violet.backend.objects.play.Strum;

class NoteHitEvent extends EventBase {

	public final note:Note;
	public final strum:Strum;

	public var direction(get, set):Int;
	function get_direction():Int return note.id;
	function set_direction(value:Int):Int return note.id = value;

	public var noteType(get, set):String;
	function get_noteType():String return note.noteType;
	function set_noteType(value:String):String return note.noteType = value;

	public var isComputer(get, never):Bool;
	function get_isComputer():Bool return note.parent.isComputer;

	public var playStrumAnim:Bool = true;

	public var animCancelled:Bool = false;
	public var animationSuffix:String = null; // null for none

	public var spawnSplash:Null<Bool> = null;
	public var spawnHoldCover:Bool;

	public var healthGain:Float = 0;

	public function new(note:Note) {
		super();
		for (i=>strumLine in PlayState.instance.strumLines.members) {
			if (strumLine == note.parent) {
				animationSuffix = PlayState.instance.defaultSuffix[i];
				break;
			}
		}
		this.note = note;
		this.strum = note.parentStrum;
		this.spawnHoldCover = note.length > 10;
		if (!isComputer) this.healthGain = Constants.DEFAULT_HEALTH_GAIN;
	}

	public function cancelAnim():Void {
		this.animCancelled = true;
	}
	public function stopStrumAnim():Void {
		this.playStrumAnim = false;
	}

}