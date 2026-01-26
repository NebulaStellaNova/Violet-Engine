package violet.backend.objects.play;

import flixel.group.FlxGroup;
import violet.data.song.ChartData;

class StrumLine extends FlxGroup {
	public var strums:FlxTypedGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Sustain>;

	public final chartData:ChartStrumLine;
	public final keyCount:Int;

	public function new(chartData:ChartStrumLine) {
		this.chartData = chartData;
		keyCount = chartData.keyCount;
		super();

		add(strums = new FlxTypedGroup<Strum>());
		add(sustains = new FlxTypedGroup<Sustain>());
		sustains.memberAdded.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		sustains.memberRemoved.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		add(notes = new FlxTypedGroup<Note>());
		notes.memberAdded.add((_:Note) -> notes.members.sort(Note.sortNotes));
		notes.memberRemoved.add((_:Note) -> notes.members.sort(Note.sortNotes));

		for (i in 0...4) strums.add(new Strum(this, i));
		for (data in chartData.notes) notes.add(new Note(this, data.id, data.time, data.length));
	}
}