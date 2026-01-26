package violet.backend.objects.play;

import violet.data.animation.NoteAnimationData;

class Strum extends NovaSprite {
	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;

	/**
	 * The skin the strum will use.
	 */
	public var skin(default, set):String;
	inline function set_skin(value:String):String {
		if (skin != value)
			reloadSkin(value);
		return skin = value;
	}

	public function new(parent:StrumLine, id:Int) {
		super();
		this.parent = parent;
		ID = id;
		skin = 'default';
	}

	public function reloadSkin(?skin:String):Void {
		function getMeta(skin:String):NoteSkinMeta {
			final jsonPath = Paths.json('$skin/meta', 'game/notes');
			if (Paths.fileExists(jsonPath, true))
				return new json2object.JsonParser<NoteSkinMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath);
			return getMeta('default');
		}
		final lastAnim:String = animation.name;
		final wasReversed:Bool = animation.curAnim.reversed;
		final lastFrame:Int = animation.curAnim.curFrame;

		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkinMeta = getMeta(skin);
		loadSprite(Paths.image('$skin/${meta.strums.assetPath ?? 'strums'}', 'game/notes'));
		for (data in meta.strums.animations.filter(data -> return data.mania == parent.strums.length)) {
			if (data.id != ID) continue;
			addAnimFromJSON(data);
		}
		var lol:Array<Float> = meta.strums.offsets != null ? [-meta.strums.offsets[0], -meta.strums.offsets[1]] : [0, 0];
		globalOffset.set(lol[0], lol[1]);

		playAnim(lastAnim, true, wasReversed, lastFrame);
	}
}

typedef NotePartMeta = {
	@:default([0, 0]) var ?offsets:Array<Float>;
	var ?assetPath:String;
	@:default([]) var animations:Array<NoteAnimationData>;
}
typedef NoteSkinMeta = {
	@:default('default') var ?fallback:String;
	var strums:NotePartMeta;
	var notes:NotePartMeta;
	var sustains:NotePartMeta;
}