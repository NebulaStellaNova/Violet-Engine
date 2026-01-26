package violet.data.noteskin;

import violet.data.animation.NoteAnimationData;

typedef NotePartMeta = {
	@:default([0, 0]) var ?offsets:Array<Float>;
	var ?assetPath:String;
	@:default([]) var animations:Array<NoteAnimationData>;
}

typedef NoteSkinData = {
	@:default('default') var ?fallback:String;
	var strums:NotePartMeta;
	var notes:NotePartMeta;
	var sustains:NotePartMeta;
}