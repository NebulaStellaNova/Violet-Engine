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
			final jsonPath = Paths.json('$skin/meta', 'images/game/notes');
			if (Paths.fileExists(jsonPath, true))
				return new json2object.JsonParser<NoteSkinMeta>().fromJson(ParseUtil.removeJsonComments(FileUtil.getFileContent(jsonPath)), jsonPath);
			return getMeta(ParseUtil.json('$skin/meta', 'images/game/notes')?.fallback ?? 'default');
		}
		final lastAnim:String = animation?.name ?? 'static';
		final wasReversed:Bool = animation?.curAnim?.reversed ?? false;
		// final lastFrame:Array<Int> = [animation?.curAnim?.curFrame ?? 0, animation?.curAnim?.numFrames ?? 1];

		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkinMeta = getMeta(skin);
		loadSprite(Paths.image('$skin/${meta.strums.assetPath ?? 'strums'}', 'game/notes'));
		for (data in meta.strums.animations) {
			if (data.keyCount != parent.keyCount) continue;
			if (data.directionId != ID) continue;
			addAnim(data.name, data.prefix, data.frameIndices, data.offsets, data.frameRate, data.looped, data.byLabel);
		}
		var lol:Array<Float> = meta.strums.offsets != null ? [-meta.strums.offsets[0], -meta.strums.offsets[1]] : [0, 0];
		globalOffset.set(lol[0], lol[1]);

		playAnim(lastAnim, true, wasReversed);
		// animation.curAnim.curFrame = Math.round(flixel.math.FlxMath.remapToRange(lastFrame[0], 0, lastFrame[1], 0, animation.curAnim.numFrames));
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