package violet.backend.objects.freeplay;

import violet.data.level.Level;

class LevelCapsule extends Capsule {

	public var data:Level;
	// to keep track of its sub items / songs
	public final children:Array<SongCapsule> = [];

	override public function new(data:Level) {
		super();
		this.data = data;
	}

}