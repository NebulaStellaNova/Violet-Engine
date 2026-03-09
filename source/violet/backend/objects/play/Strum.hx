package violet.backend.objects.play;

import violet.backend.audio.Conductor;
import violet.data.noteskin.NoteSkin;
import violet.data.noteskin.NoteSkinRegistry;

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
	var skinMeta:NoteSkin;

	/**
	 * Used to help "glowLength".
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	public var glowLength:Float = 4;

	/**
	 * If true after the "glowlength" is reached the animation will go back to "static".
	 */
	public var willReset:Bool = false;

	public final splashes:Array<NovaSprite> = [];
	public final holdCovers:Array<NovaSprite> = [];

	public function new(parent:StrumLine, id:Int) {
		super();
		this.parent = parent;
		ID = id;
		skin = 'default';
	}

	public function reloadSkin(?skin:String):Void {
		final lastAnim:String = animation?.name ?? 'static';
		final wasReversed:Bool = animation?.curAnim?.reversed ?? false;
		// final lastFrame:Array<Int> = [animation?.curAnim?.curFrame ?? 0, animation?.curAnim?.numFrames ?? 1];

		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		final meta:NoteSkin = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(meta.getStrumAssetPath());
		for (data in meta.getStrumAnimations(ID, parent.keyCount))
			addAnimFromData(data);
		var lol:Array<Float> = meta.getStrumOffsets();
		globalOffset.set(lol[0], lol[1]);

		playAnim(lastAnim, true, wasReversed); updateHitbox();
		// animation.curAnim.curFrame = Math.round(flixel.math.FlxMath.remapToRange(lastFrame[0], 0, lastFrame[1], 0, animation.curAnim.numFrames));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (willReset && animation?.name != 'static')
			if (glowLength > 0 ? (lastHit + (Conductor.stepLengthMs * glowLength) < Conductor.songPosition) : (animation.name == null || animation.finished))
				playStrumAnim(parent.isComputer ? 'static' : 'press');

		for (holdCover in holdCovers) {
			if (holdCover == null) continue;
			if (holdCover.exists && holdCover.animation.name != 'end') {
				holdCover.x = this.x - (holdCover.width/2);
				holdCover.y = this.y - (holdCover.height/2);
				holdCover.x += skinMeta.getHoldCoverOffsets()[0];
				holdCover.y += skinMeta.getHoldCoverOffsets()[1];
			}
		}
	}

	public function playStrumAnim(name:String, reset:Bool = false, forced:Bool = true, reversed:Bool = false, frame:Int = 0):Void {
		if (this.animation.exists(name)) {
			playAnim(name, forced, reversed, frame);
			if (!this.anims.exists(name)) this.offset.set();
			centerOffsets();
			centerOrigin();
			if (reset) lastHit = Conductor.songPosition;
			willReset = reset;
		}
	}

	public function spawnSplash() {
		final skin:String = skin ?? this.skin ?? 'default';
		this.skinMeta = NoteSkinRegistry.getNoteSkinByID(skin);

		var splash = new NovaSprite(0, 0, skinMeta.getSplashAssetPath());
		for (data in skinMeta.getSplashAnimations(ID, parent.keyCount))
			splash.addAnimFromData(data);

		splash.playAnim('${FlxG.random.int(1, 2)}', true); // Make this auto check how many animations lol.
		// splash.cameras = this.parent.cameras;
		splash.centerOffsets();
		splash.centerOrigin();
		splash.animation.onFinish.add((_)->{
			this.parent.remove(splash);
			this.splashes.remove(splash);
			splash.destroy();
		});
		splash.x = this.x - (splash.width/2);
		splash.y = this.y - (splash.height/2);
		splash.x += skinMeta.getSplashOffsets()[0];
		splash.y += skinMeta.getSplashOffsets()[1];
		this.parent.add(splash);
		this.splashes.push(splash);
	}


	public function spawnHoldCover() {
		var holdCover = new NovaSprite(0, 0, skinMeta.getHoldCoverAssetPath());
		for (data in skinMeta.getHoldCoverAnimations(ID, parent.keyCount)) holdCover.addAnimFromData(data);

		holdCover.playAnim('start', true); // Make this auto check how many animations lol.
		holdCover.centerOffsets();
		holdCover.centerOrigin();
		holdCover.animation.onFinish.add(name -> {
			switch (name) {
				case 'start':
					holdCover.playAnim('hold', true);
				case 'end':
					this.parent.remove(holdCover);
					holdCover.destroy();
			}
		});
		holdCover.x = this.x - (holdCover.width/2);
		holdCover.y = this.y - (holdCover.height/2);
		holdCover.x += skinMeta.getHoldCoverOffsets()[0];
		holdCover.y += skinMeta.getHoldCoverOffsets()[1];
		this.parent.add(holdCover);
		this.holdCovers.push(holdCover);

	}

	public final sustainBlacklist:Array<Note> = [];
	public function endHoldCover(pop:Bool, parentNote:Null<Note>) {
		if (parentNote != null) {
			if (sustainBlacklist.contains(parentNote)) return;
			sustainBlacklist.push(parentNote);
		}
		for (i in holdCovers) {
			this.holdCovers.remove(i);
			i.playAnim("end", true);
			if (!pop) i.animation.finish();
		}
	}
}
