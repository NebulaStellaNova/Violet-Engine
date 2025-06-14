package backend.objects.play;

import backend.filesystem.Paths;

class SustainNote extends NovaSprite {
	public var direction(get, set):Int;
	inline function get_direction():Int
		return parentNote.direction;
	inline function set_direction(value:Int):Int
		return parentNote.direction = value;

	public var typeID(get, set):Int;
	inline function get_typeID():Int
		return parentNote.typeID;
	inline function set_typeID(value:Int):Int
		return parentNote.typeID = value;

	public var type(get, set):String;
	inline function get_type():String
		return parentNote.type;
	inline function set_type(value:String):String
		return parentNote.type = value;

	public var skin(get, set):String;
	inline function get_skin():String
		return parentNote.skin;
	inline function set_skin(value:String):String
		return parentNote.skin = value;

	public var time:Float = 0;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var strumlineID(get, set):Int;
	inline function get_strumlineID():Int
		return parentNote.strumlineID;
	inline function set_strumlineID(value:Int):Int
		return parentNote.strumlineID = value;

	public var parentNote:Note;
	public var parentStrum(get, set):Strum;
	inline function get_parentStrum():Strum
		return parentNote.parentStrum;
	inline function set_parentStrum(value:Strum):Strum
		return parentNote.parentStrum = value;

	public var skinData:NoteSkin;

	public var isEnd:Bool;

	override public function new(parent:Note, time:Float, isEnd:Bool = false) {
		super();

		parentNote = parent;
		this.time = time;
		this.isEnd = isEnd;

		reloadSkin();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		// prevent scaling on sustain end
		if (isEnd) return;

		// setGraphicSize
		scale.y = (67.9 / frameHeight) * parentNote.scrollSpeed;

		// updateHitbox
		height = Math.abs(scale.y) * frameHeight;
		offset.y = -0.5 * (height - frameHeight) - (offsets.exists(animation.name) ? offsets.get(animation.name)[1] : 0);

		// centerOrigin
		origin.y = frameHeight * 0.5;
	}

	public function reloadSkin() {
		var target = skin;
		if (!Paths.fileExists(Paths.json('images/game/notes/$skin/meta')))
			target = 'default';
		else if (!Paths.fileExists(Paths.image('game/notes/$skin/sustains')))
			target = 'default';

		loadSprite(Paths.image('game/notes/$target/sustains'));
		skinData = Paths.parseJson('images/game/notes/$target/meta');
		var globalOffset:Array<Float> = skinData.offsets.global ??= [0, 0];
		for (i=>color in Note.colorStrings) {
			addAnim(Note.colorStrings[i] + ' piece', '$color hold piece', [skinData.offsets.sustains[0]+globalOffset[0], skinData.offsets.sustains[1]+globalOffset[1]]);
			addAnim(Note.colorStrings[i] + ' end', '$color hold end', [skinData.offsets.sustains[0]+globalOffset[0], skinData.offsets.sustains[1]+globalOffset[1]]);
		}
		playAnim(Note.colorStrings[this.direction] + (isEnd ? ' end' : ' piece'));
		this.scale.x = 0.7;
		this.updateHitbox();
	}
}