package violet.backend.objects.play.underlay;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import violet.backend.options.Options;
import violet.backend.utils.MathUtil;

class StrumUnderlay extends FlxTypedGroup<FlxBackdrop> {

	public final parent:Strum;

	public final bg:FlxBackdrop;
	public final flashBg:FlxBackdrop;

	override public function new(parent:Strum) {
		this.parent = parent;
		this.ID = parent.ID;

		super(2);

		bg = new FlxBackdrop(Y);
		flashBg = new FlxBackdrop(Y);
		for (bg in [bg, flashBg]) {
			bg.makeGraphic(1, FlxG.height, bg == flashBg ? FlxColor.WHITE : FlxColor.BLACK);
			bg.scale.x = Note.swagWidth;
			bg.antialiasing = false;
			bg.updateHitbox();
			add(bg);
		}

		flashBg.alpha = 0;
		setColor();
	}

	public function setColor(?color:FlxColor):Void
		flashBg.color = color ?? FlxColor.GRAY;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		bg.x = flashBg.x = parent.x + @:privateAccess parent.styleMeta.getUnderlayOffset();
		bg.alpha = Options.data.underlayOpacity / 100;

		if (parent.animation.name == 'confirm') {
			if (parent.animation.curAnim.curFrame == 0)
				flashBg.alpha = Options.data.laneFlashIntensity / 100;
		} else if (parent.animation.name == 'press')
			flashBg.alpha = 0.25 * (Options.data.laneFlashIntensity / 100);

		flashBg.alpha = MathUtil.lerp(flashBg.alpha, 0, 0.2);
	}

}