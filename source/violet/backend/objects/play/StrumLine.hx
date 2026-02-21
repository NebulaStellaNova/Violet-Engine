package violet.backend.objects.play;

import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import violet.data.chart.Chart;

class StrumLine extends FlxGroup {
	public final strums:FlxTypedGroup<Strum>;
	public final notes:FlxTypedGroup<Note>;
	public final sustains:FlxTypedGroup<Sustain>;

	public final chartData:_ChartStrumLine;
	public var keyCount(default, null):Int;

	public final scale:FlxCallbackPoint;

	public function new(chartData:_ChartStrumLine) {
		this.chartData = chartData;
		super();

		scale = new FlxCallbackPoint((point) -> {
			for (strum in strums) {
				strum.scale.set(0.7, 0.7);
				strum.scale.scale(strumScale);
				strum.updateHitbox();
			}
		});

		add(strums = new FlxTypedGroup<Strum>());
		add(sustains = new FlxTypedGroup<Sustain>());
		sustains.memberAdded.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		sustains.memberRemoved.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		add(notes = new FlxTypedGroup<Note>());
		notes.memberAdded.add((_:Note) -> notes.members.sort(Note.sortNotes));
		notes.memberRemoved.add((_:Note) -> notes.members.sort(Note.sortNotes));

		generateStrums(chartData.keyCount);

		strumScale = chartData.strumScale;
		strumSpacing = chartData.strumSpacing;
		scale.set(1, 1); setPosition(chartData.strumPosition[0], chartData.strumPosition[1], chartData.strumPosIsPure);
	}

	public var strumScale:Float;
	public var strumSpacing:Float;

	public function setPosition(x:Float = 0, y:Float = 0, purePos:Bool = true):Void {
		for (i => strum in strums) {
			var _x:Float = x;
			if (!purePos) _x = (getDefaultCamera().width * x) - ((Note.swagWidth * strumScale * (keyCount / 2) - 0.5 * strumSpacing) + Note.swagWidth * 0.5 * strumScale);
			strum.x = _x + (Note.swagWidth * strumScale * strumSpacing * i);
			strum.y = y + (Note.swagWidth * 0.5) - (Note.swagWidth * strumScale * 0.5);
		}
	}

	public function generateStrums(mania:Int = 4):Void {
		while (strums.length != 0) {
			final strum = strums.members[strums.length - 1];
			strums.remove(strum);
			strum.destroy();
		}
		keyCount = mania;
		for (i in 0...keyCount) strums.add(new Strum(this, i));
	}
	public function generateNotes():Void {
		for (data in chartData.notes) notes.add(new Note(this, data.id, data.time, data.length));
	}

	override public function destroy() {
		scale.put();
		super.destroy();
	}
}