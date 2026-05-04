package violet.backend.objects.play.underlay;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import violet.backend.options.Options;

class StrumLineUnderlay extends FlxBackdrop {

	public final parent:StrumLine;
	public final lanes:FlxTypedGroup<StrumUnderlay>;

	override public function new(parent:StrumLine) {
		this.parent = parent;
		super(Y);
		makeGraphic(1, FlxG.height, FlxColor.BLACK);
		lanes = new FlxTypedGroup<StrumUnderlay>();
		antialiasing = false;
	}

	public function generateIndividualLanes():Void {
		while (lanes.length != 0) {
			final lane = lanes.members[lanes.length - 1];
			lanes.remove(lane);
			lane.destroy();
		}
		for (strum in parent.strums)
			lanes.add(new StrumUnderlay(strum));
	}

	override public function update(elapsed:Float):Void {
		if (Options.data.laneUnderlay) {
			if (!Options.data.fancyLaneUnderlay) {
				this.alpha = Options.data.underlayOpacity / 100;
				this.x = getMinXStrums() + (getStrumsWidth() / 2);
				this.scale.x = (this.width = getStrumsWidth()) + (Options.data.laneGrow * 2);
			} else lanes.update(elapsed);
		}
	}

	override public function draw():Void {
		if (Options.data.laneUnderlay) {
			if (Options.data.fancyLaneUnderlay)
				lanes.draw();
			else super.draw();
		}
	}

	override public function destroy():Void {
		lanes.destroy();
		super.destroy();
	}

	inline function getMinXStrums():Float {
		var value = Math.POSITIVE_INFINITY;

		for (strum in parent.strums) {
			if (strum == null) continue;
			if (!strum.visible) continue;
			if (strum.alpha <= 0) continue;

			var minX:Float = strum.x + @:privateAccess strum.styleMeta.getUnderlayOffset();
			if (minX < value) value = minX;
		}

		return value;
	}
	inline function getStrumsWidth():Float {
		var value = Math.NEGATIVE_INFINITY;

		for (strum in parent.strums) {
			if (strum == null) continue;
			if (!strum.visible) continue;
			if (strum.alpha <= 0) continue;

			var maxX:Float = strum.x + Note.swagWidth + @:privateAccess strum.styleMeta.getUnderlayOffset();
			if (maxX > value) value = maxX;
		}

		return value - getMinXStrums();
	}

}