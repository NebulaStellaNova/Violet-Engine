package violet.backend.objects.play;

import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import violet.data.song.ChartData;

class StrumLine extends FlxGroup {
	public final strums:FlxTypedGroup<Strum>;
	public final notes:FlxTypedGroup<Note>;
	public final sustains:FlxTypedGroup<Sustain>;

	public final chartData:ChartStrumLine;
	public final keyCount:Int;

	public final scale:FlxCallbackPoint;

	public function new(chartData:ChartStrumLine) {
		this.chartData = chartData;
		keyCount = chartData.keyCount;
		super();

		scale = new FlxCallbackPoint((point) -> {
			for (strum in strums) {
				strum.scale.set(1, 1);
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

		for (i in 0...keyCount) strums.add(new Strum(this, i));

		strumSpacing = chartData.strumSpacing;
		strumScale = chartData.strumScale ?? 1;
		scale.set(1, 1); setPosition(FlxG.width / 2, FlxG.height / 2);

		// for (data in chartData.notes) notes.add(new Note(this, data.id, data.time, data.length));
	}

	public var strumSpacing:Float;
	public var strumScale:Float;

	public function setPosition(x:Float = 0, y:Float = 0):Void {
		for (i => strum in strums) {
			strum.x = x + (Note.swagWidth * strumScale * strumSpacing * i);
			strum.y = y + (Note.swagWidth * 0.5) - (Note.swagWidth * strumScale * 0.5);
		}
	}

	override public function destroy() {
		scale.put();
		super.destroy();
	}
}