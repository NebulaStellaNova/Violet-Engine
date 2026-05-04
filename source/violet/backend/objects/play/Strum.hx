package violet.backend.objects.play;

import violet.backend.audio.Conductor;
import violet.backend.options.Options;
import violet.data.notestyles.NoteStyle;
import violet.data.notestyles.NoteStyleRegistry;

class Strum extends NovaSprite {

	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;

	/**
	 * The style the strum will use.
	 */
	public var style(default, set):String;
	inline function set_style(value:String):String {
		if (style != value)
			reloadStyle(value);
		return style = value;
	}
	var styleMeta:NoteStyle;

	/**
	 * The scroll speed of this strums notes.
	 */
	public var scrollSpeed:Null<Float>;
	/**
	 * The scroll angle of this strums notes.
	 */
	public var scrollAngle:Null<Float>;

	/**
	 * Used to help "glowLength".
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	public var glowLength:Float = 1.2;

	/**
	 * If true after the "glowlength" is reached the animation will go back to "static".
	 */
	public var willReset:Bool = false;

	public final splashes:Array<StrumElement> = [];
	public final holdCovers:Array<StrumElement> = [];
	public var holdCover:StrumElement;

	public function new(parent:StrumLine, id:Int) {
		super();
		this.parent = parent;
		ID = id;
		style = null;
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(parent.noteStyle ?? 'default');

		final daScale:Float = styleMeta.strumProperties.scale;
		scale.set(daScale, daScale);
		scale.scale(parent.strumScale);
		updateHitbox();

		spawnSplash();
		for (element in splashes) element.animation.finish();
		spawnHoldCover();
		for (element in holdCovers) element.animation.finish();
	}

	public function reloadStyle(?style:String):Void {
		final lastAnim:String = animation?.name ?? 'static';
		final wasReversed:Bool = animation?.curAnim?.reversed ?? false;
		// final lastFrame:Array<Int> = [animation?.curAnim?.curFrame ?? 0, animation?.curAnim?.numFrames ?? 1];

		this.anims.clear();
		animation.destroyAnimations();
		final style:String = style ?? this.style ?? parent.noteStyle ?? 'default';
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(style);
		loadSprite(styleMeta.getStrumAssetPath());
		for (data in styleMeta.getStrumAnimations(ID, parent.keyCount))
			addAnimFromData(data);
		globalOffset.set(styleMeta.strumOffset.x, styleMeta.strumOffset.y);
		this.antialiasing = styleMeta.isStrumPixel();

		playAnim(lastAnim, true, wasReversed);
		// animation.curAnim.curFrame = Math.round(flixel.math.FlxMath.remapToRange(lastFrame[0], 0, lastFrame[1], 0, animation.curAnim.numFrames));
		final daScale:Float = styleMeta.strumProperties.scale;
		scale.set(daScale, daScale);
		scale.scale(parent.strumScale);
		updateHitbox(); alpha = styleMeta.strumProperties.alpha;
		blend = styleMeta.strumProperties.blendMode;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (willReset && animation?.name != 'static')
			if (glowLength > 0 ? (lastHit + (Conductor.stepLengthMs * glowLength) < Conductor.songPosition) : (animation.name == null || animation.finished)) {
				var targetAnim = parent.isComputer ? 'static' : 'press';
				if (animation.name != targetAnim) playStrumAnim(targetAnim, true);
			}

		if (holdCover == null) return;
		if (holdCover.exists && holdCover.animation.name != 'end') {
			holdCover.setPosition(this.x - (holdCover.width/2) + styleMeta.holdcoverOffset.x, this.y - (holdCover.height/2) + styleMeta.holdcoverOffset.y);
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

	public var splashBin:Map<String, Array<StrumElement>> = [];
	public var splashBinIndex:Map<String, Int> = [];
	public var holdCoverBin:Map<String, Array<StrumElement>> = [];

	public function spawnSplash(?note:Note):Void {
		if (!Options.data.enableNoteSplashes) return;
		var finalMeta;
		if (note?.style != null) {
			finalMeta = NoteStyleRegistry.getNoteStyleByID(note.style);
		} else {
			finalMeta = styleMeta;
		}

		if (!splashBin.exists(finalMeta.id)) splashBin.set(finalMeta.id, []);
		if (!splashBinIndex.exists(finalMeta.id)) splashBinIndex.set(finalMeta.id, 0);

		var index:Int = splashBinIndex.get(finalMeta.id) % 3;
		var bin:Array<StrumElement> = splashBin.get(finalMeta.id);

		var splash:StrumElement = null;

		if (bin[index] == null) {
			splash = new StrumElement(this, finalMeta.getSplashAssetPath());
			for (data in finalMeta.getSplashAnimations(ID, parent.keyCount))
				splash.addAnimFromData(data);
			bin[index] = splash;
			this.splashes.push(splash);
			this.parent.add(splash);
		} else {
			splash = bin[index];
		}

		splash.playAnim(FlxG.random.getObject(splash.animationList), true);
		splash.setScale(finalMeta.splashProperties.scale);
		splash.animation.onFinish.addOnce(name -> splash.visible = false);
		splash.setPosition(this.x - (splash.width/2) + finalMeta.splashOffset.x, this.y - (splash.height/2) + finalMeta.splashOffset.y);
		splash.antialiasing = finalMeta.isSplashPixel();
		splash.alpha = finalMeta.splashProperties.alpha;
		splash.blend = finalMeta.splashProperties.blendMode;
		splash.visible = true;

		splashBin.set(finalMeta.id, bin);
		splashBinIndex.set(finalMeta.id, index + 1);
	}


	public function spawnHoldCover():Void {
		if (!Options.data.enableHoldCovers) return;
		if (holdCover != null) {
			holdCover.playAnim('end', true);
			holdCover.animation.finish();
		}

		final styleID:String = styleMeta.id;
		if (!holdCoverBin.exists(styleID)) holdCoverBin.set(styleID, []);
		final bin:Array<StrumElement> = holdCoverBin.get(styleID);

		var holdCover:StrumElement = null;
		for (element in bin) {
			if (!element.exists) {
				holdCover = element;
				break;
			}
		}

		if (holdCover == null) {
			holdCover = new StrumElement(this, styleMeta.getHoldCoverAssetPath());
			for (data in styleMeta.getHoldCoverAnimations(ID, parent.keyCount))
				holdCover.addAnimFromData(data);

			holdCover.animation.onFinish.add(name -> {
				switch (name) {
					case 'start':
						holdCover.playAnim('hold', true);
					case 'end':
						if (this.holdCover == holdCover)
							this.holdCover = null;
						holdCover.kill();
				}
			});
			bin.push(holdCover);
			this.holdCovers.push(holdCover);
			this.parent.add(holdCover);
		}

		this.holdCover = holdCover;
		holdCover.revive();
		holdCover.playAnim('start', true);
		holdCover.setScale(styleMeta.holdCoverProperties.scale);
		holdCover.setPosition(this.x - (holdCover.width/2) + styleMeta.holdcoverOffset.x, this.y - (holdCover.height/2) + styleMeta.holdcoverOffset.y);
		holdCover.antialiasing = styleMeta.isHoldCoverPixel();
		holdCover.alpha = styleMeta.holdCoverProperties.alpha;
		holdCover.blend = styleMeta.holdCoverProperties.blendMode;
	}

}
