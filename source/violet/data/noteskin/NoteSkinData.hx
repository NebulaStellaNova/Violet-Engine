package violet.data.noteskin;

import violet.data.animation.NoteAnimationData;

typedef NotePartMeta = {
	var ?offsets:Array<Float>;
	var ?assetPath:String;
	var animations:Array<NoteAnimationData>;
}

typedef NoteSkinData = {
	var name:String;
	var ?assetPath:String;
	var ?offsets:Array<Float>;
	var ?fallback:String;
	var strums:NotePartMeta;
	var notes:NotePartMeta;
	var sustains:NotePartMeta;
	var splashes:NotePartMeta;
}