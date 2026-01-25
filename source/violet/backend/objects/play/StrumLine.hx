package violet.backend.objects.play;

import flixel.group.FlxGroup;

class StrumLine extends FlxGroup {
	public var strums:FlxTypedGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Sustain>;

	public function new() {
		super();

		add(strums = new FlxTypedGroup<Strum>());
		for (i in 0...4) strums.add(new Strum(this, i));

		add(sustains = new FlxTypedGroup<Sustain>());
		sustains.memberAdded.add((_:Sustain) -> members.sort(Note.sortTail));
		sustains.memberRemoved.add((_:Sustain) -> members.sort(Note.sortTail));
		add(notes = new FlxTypedGroup<Note>());
		notes.memberAdded.add((_:Note) -> members.sort(Note.sortNotes));
		notes.memberRemoved.add((_:Note) -> members.sort(Note.sortNotes));
	}

	public function parse(data:violet.data.song.ChartData.ChartStrumLine):Void {
		for (base in data.notes)
			notes.add(new Note(this, base.id, base.time, base.length));
	}
}