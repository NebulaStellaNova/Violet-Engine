package violet.backend.objects.play;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import violet.backend.options.Options;
import violet.backend.utils.MathUtil;

@:allow(violet.backend.objects.play.StrumUnderlay)
private class InternalUnderlay extends FlxBackdrop {

	public final parent:StrumUnderlay;
	public var _strum(get, never):Strum;
	inline function get__strum():Strum
		return parent.parent;

	override function new(parent:StrumUnderlay) {
		this.parent = parent;
		super(FlxAxes.Y);
		makeGraphic(1, FlxG.height);
		color = FlxColor.BLACK;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

}

class StrumUnderlay extends FlxTypedGroup<InternalUnderlay> {

	public final parent:Strum;

	public final bg:InternalUnderlay;
	public final flashBg:InternalUnderlay;

	public final flashColor:FlxColor;

	override public function new(parent:Strum, defaultFlashColor:FlxColor = FlxColor.GRAY) {
		this.parent = parent;

		super(2);

		add(bg = new InternalUnderlay(this));
		add(flashBg = new InternalUnderlay(this));

		flashBg.color = flashColor = defaultFlashColor;

		bg.alpha = Options.data.underlayOpacity / 100;
		flashBg.alpha = 0;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		bg.scale.x = flashBg.scale.x = Note.swagWidth;
		bg.x = flashBg.x = parent.x - (parent.width / 2);

		if (parent.animation.name == 'confirm') {
			if (parent.animation.curAnim.curFrame == 0)
				flashBg.alpha = Options.data.laneFlashIntensity / 100;
		} else if (parent.animation.name == 'press')
			flashBg.alpha = 0.25 * (Options.data.laneFlashIntensity / 100);

		flashBg.alpha = MathUtil.lerp(flashBg.alpha, 0, 0.2);
	}

}