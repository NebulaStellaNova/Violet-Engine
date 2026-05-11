package violet.backend.objects.play;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import funkin.vis.dsp.SpectralAnalyzer;
import violet.backend.audio.Conductor;
import violet.backend.filesystem.Paths;
import violet.backend.utils.NovaUtils;

class ABotVisualizer extends FlxTypedSpriteGroup<FlxSprite> {

	public var analyzer:Null<SpectralAnalyzer> = null;
	public var analyzerLevelsCache:Array<Bar> = [];

	public var snd:Null<FlxSound> = null;

	public var barCount(default, null):Int;
	public var frameCount:Int = 6;
	public var frameFlip:Bool = true;

	public var minDb:Float = -65;
	public var maxDb:Float = -25;
	public var minFreq:Float = 10;
	public var maxFreq:Float = 22000;
	public var fftN:Int = 256;

	public function new(
		x:Float = 0,
		y:Float = 0,
		?snd:FlxSound,
		atlasPath:String = "characters/abot/aBotViz",
		?barX:Array<Float>,
		?barY:Array<Float>,
		barPrefix:String = "viz",
		barCount:Int = 7,
		visScale:Float = 1,
		pixel:Bool = false
	) {
		super(x, y);

		this.snd = snd ?? Conductor.instrumental;
		this.barCount = barCount;

		if (barX == null) {
			barX = pixel
				? [0, 7 * 6, 8 * 6, 9 * 6, 10 * 6, 6 * 6, 7 * 6]
				: [0, 59, 56, 66, 54, 52, 51];
		}

		if (barY == null) {
			barY = pixel
				? [0, -2 * 6, -1 * 6, 0, 0, 1 * 6, 2 * 6]
				: [0, -8, -3.5, -0.4, 0.5, 4.7, 7];
		}

		var visFrames:FlxAtlasFrames = NovaUtils.getSparrowFrames(Paths.image(atlasPath));

		for (index in 0...barCount) {
			var posX:Float = 0;
			var posY:Float = 0;

			for (i in 0...index + 1) {
				posX += barX[i] ?? 0;
				posY += barY[i] ?? 0;
			}

			var bar:FlxSprite = new FlxSprite(posX, posY);
			bar.frames = visFrames;
			bar.antialiasing = !pixel;
			bar.scale.set(visScale, visScale);
			bar.updateHitbox();
			bar.animation.addByPrefix("VIZ", '$barPrefix${index + 1}0', 0);
			bar.animation.play("VIZ", false, false, 1);

			add(bar);
		}
	}

	public function initAnalyzer(?sound:FlxSound):Void {
		if (sound != null) snd = sound;
		if (snd == null) snd = Conductor.instrumental;
		if (snd == null) return;

		@:privateAccess {
			if (snd._channel == null || snd._channel.__audioSource == null) return;
			analyzer = new SpectralAnalyzer(snd._channel.__audioSource, barCount, 0.1, 40);
		}

		analyzer.minDb = minDb;
		analyzer.maxDb = maxDb;
		analyzer.minFreq = minFreq;
		analyzer.maxFreq = maxFreq;

		#if sys
		analyzer.fftN = fftN;
		#end
	}

	public function dumpSound():Void {
		snd = null;
		analyzer = null;
		analyzerLevelsCache.resize(0);
	}

	override public function destroy():Void {
		dumpSound();
		super.destroy();
	}

	override public function draw():Void {
		super.draw();
		drawFFT();
	}

	public function drawFFT():Void {
		if (analyzer == null && snd != null)
			initAnalyzer();

		analyzerLevelsCache = analyzer != null
			? analyzer.getLevels()
			: getDefaultLevels();

		for (i in 0...min(members.length, analyzerLevelsCache.length)) {
			var bar = members[i];
			if (bar == null) continue;

			var animFrame:Int = (FlxG.sound.volume == 0 || FlxG.sound.muted)
				? 0
				: Math.round(analyzerLevelsCache[i].value * frameCount);

			bar.visible = animFrame > 0;

			animFrame -= 1;
			animFrame = Std.int(Math.min(frameCount - 1, animFrame));
			animFrame = Std.int(Math.max(0, animFrame));

			if (frameFlip)
				animFrame = Std.int(Math.abs(animFrame - (frameCount - 1)));

			if (bar.animation.curAnim != null)
				bar.animation.curAnim.curFrame = animFrame;
		}
	}

	static inline function min(x:Int, y:Int):Int
		return x > y ? y : x;

	function getDefaultLevels():Array<Bar> {
		var result:Array<Bar> = [];

		for (i in 0...barCount)
			result.push({value: 0, peak: 0});

		return result;
	}
}
