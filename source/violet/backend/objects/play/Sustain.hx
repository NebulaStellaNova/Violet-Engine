package violet.backend.objects.play;

import violet.data.noteskin.NoteSkin;
import violet.data.noteskin.NoteSkinRegistry;

class Sustain extends NovaSprite {
	/**
	 * The parent strumline.
	 */
	public var parent(get, never):StrumLine;
	inline function get_parent():StrumLine
		return parentNote.parent;
	/**
	 * The parent note.
	 */
	public final parentNote:Note;
	/**
	 * The parent strum.
	 */
	public var parentStrum(get, never):Strum;
	inline function get_parentStrum():Strum
		return parentNote.parentStrum;

	@:allow(violet.backend.objects.play.Note)
	var preventAutoSkinSet:Bool = true;
	/**
	 * The direction id of the sustain.
	 */
	public var id(get, set):Int;
	inline function get_id():Int return parentNote.id;
	inline function set_id(value:Int):Int return parentNote.id = value;
	/**
	 * The current position within the song.
	 */
	public var time:Float;
	/**
	 * The skin the sustain will use.
	 */
	public var skin(get, set):String;
	inline function get_skin():String return parentNote.skin;
	inline function set_skin(value:String):String return parentNote.skin = value;

	/**
	 * States if this is the end piece of a sustain tail.
	 */
	public final isEnd:Bool;

	public function new(parent:Note, time:Float, isEnd:Bool) {
		super(-10000, -10000);
		parentNote = parent;
		this.time = time;
		this.isEnd = isEnd;
		skin = 'default';
		this.parent.sustains.add(this);
	}

	public function reloadSkin(?skin:String):Void {
		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkin = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(meta.getSustainAssetPath());
		for (data in meta.getSustainAnimations(ID, parent.keyCount))
			addAnimFromJSON(data);
		var lol:Array<Float> = meta.getSustainOffsets();
		globalOffset.set(lol[0], lol[1]);

		playAnim(isEnd ? 'end' : 'tail', true); updateHitbox();
	}
}