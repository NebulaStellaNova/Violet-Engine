package violet.backend.objects.play;

import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import violet.backend.audio.Conductor;
import violet.backend.filesystem.Paths;
import violet.backend.objects.BopperSpriteGroup;
import violet.backend.objects.NovaSprite;

class ABot extends BopperSpriteGroup {

	public var isPixel:Bool;
	public var body:NovaSprite;
	public var eyes:NovaSprite;
	public var eyeWhites:FlxSprite;
	public var stereoBG:FlxSprite;
	public var visualizer:ABotVisualizer;

	public function new(x:Float = 0, y:Float = 0, ?snd:FlxSound, pixel:Bool = false) {
		super(x, y);

		this.isPixel = pixel;
		this.snd = snd ?? Conductor.instrumental;

		if (pixel) buildPixel();
		else buildNormal();
	}

	public var snd(default, set):Null<FlxSound>;
	function set_snd(value:Null<FlxSound>):Null<FlxSound> {
		@:bypassAccessor snd = value;
		if (visualizer != null) visualizer.snd = value;
		return value;
	}

	function buildNormal():Void {
		eyeWhites = new FlxSprite(40, 250);
		eyeWhites.makeGraphic(160, 60, FlxColor.WHITE);
		eyeWhites.z = -10;
		add(eyeWhites);

		stereoBG = new FlxSprite(150, 30, Paths.image("characters/abot/stereoBG"));
		stereoBG.antialiasing = true;
		stereoBG.z = -8;
		add(stereoBG);

		eyes = new NovaSprite(50, 238, Paths.image("characters/abot/systemEyes"));
		eyes.addAnim("idle", "a bot eyes lookin", null, [0, 0], 24, false, false);
		eyes.playAnim("idle");
		eyes.z = -5;
		add(eyes);

		visualizer = new ABotVisualizer(207, 84, snd);
		visualizer.z = -1;
		add(visualizer);

		body = new NovaSprite(0, 0, Paths.image("characters/abot/abotSystem"));
		body.addAnim("idle", "Abot System", null, [0, 0], 24, false, false);
		body.playAnim("idle", true, false, 1);
		add(body);
	}

	function buildPixel():Void {
		body = new NovaSprite(0, 0, Paths.image("characters/abotPixel/aBotPixel"));
		body.antialiasing = false;
		body.scale.set(6, 6);
		body.addAnim("idle", "idle", null, [0, 0], 24, true);
		body.playAnim("idle");
		body.updateHitbox();
		add(body);

		visualizer = new ABotVisualizer(18 * 6, 8 * 6, snd, "characters/abotPixel/aBotVizPixel", null, null, "viz", 7, 6, true);
		add(visualizer);
	}

	public function initAnalyzer(?sound:FlxSound):Void {
		visualizer?.initAnalyzer(sound ?? snd);
	}

	public function dumpSound():Void {
		visualizer?.dumpSound();
		snd = null;
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		if (!isPixel && body != null)
			body.playAnim("idle", true, false, 1);
	}

	override public function destroy():Void {
		dumpSound();
		super.destroy();
	}
}
