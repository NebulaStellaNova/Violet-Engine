package violet.data.noteskin;

import violet.data.animation.NoteAnimationData;

typedef NoteSkinProperties = {
	var ?scale:Float;
	var ?alpha:Float;
	var ?blendMode:String;
}

typedef NotePartMeta = {
	var ?assetPath:String;
	var ?offsets:Array<Float>;
	var ?isPixel:Bool;
	var ?properties:NoteSkinProperties;
	var animations:Array<NoteAnimationData>;
}

typedef NoteSkinData = {
	var name:String;
	var ?fallback:String;
	var ?assetPath:String;
	var ?offsets:Array<Float>;
	var ?isPixel:Bool;
	var ?properties:NoteSkinProperties;
	var strums:NotePartMeta;
	var notes:NotePartMeta;
	var sustains:NotePartMeta;
	// not all skins will have them
	var ?splashes:NotePartMeta;
	var ?holdcovers:NotePartMeta;
}