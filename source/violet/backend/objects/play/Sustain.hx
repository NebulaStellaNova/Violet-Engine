package violet.backend.objects.play;

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
		parent.sustains.add(this);
	}

	public function reloadSkin(?skin:String):Void {
		function getMeta(skin:String):NoteSkinMeta {
			final jsonPath = Paths.json('$skin/meta', 'game/notes');
			if (Paths.fileExists(jsonPath, true))
				return new json2object.JsonParser<NoteSkinMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath);
			return getMeta('default');
		}

		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkinMeta = getMeta(skin);
		loadSprite(Paths.image('$skin/${meta.sustains.assetPath ?? 'sustains'}', 'game/notes'));
		for (data in meta.sustains.animations.filter(data -> return data.mania == parent.strums.length)) {
			if (data.id != id) continue;
			addAnimFromJSON(data);
		}
		var lol:Array<Float> = meta.sustains.offsets != null ? [-meta.sustains.offsets[0], -meta.sustains.offsets[1]] : [0, 0];
		globalOffset.set(lol[0], lol[1]);

		playAnim(isEnd ? 'end' : 'tail', true);
	}
}