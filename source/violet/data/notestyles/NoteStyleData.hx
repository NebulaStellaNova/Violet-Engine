package violet.data.notestyles;

import violet.data.animation.NoteAnimationData;

typedef NoteStyleProperties = {
	var ?scale:Float;
	var ?alpha:Float;
	var ?blendMode:String;
}

typedef NotePartMeta = {
	var ?assetPath:String;
	var ?offsets:Array<Float>;
	var ?isPixel:Bool;
	var ?properties:NoteStyleProperties;
	var animations:Array<NoteAnimationData>;

}
typedef SustainPartMeta = {
	> NotePartMeta,
	var ?gapFixAmount:Float;
}

typedef NoteStyleData = {
	var name:String;
	var ?fallback:String;
	var ?assetPath:String;
	var ?offsets:Array<Float>;
	var ?isPixel:Bool;
	var ?properties:NoteStyleProperties;
	var strums:NotePartMeta;
	var notes:NotePartMeta;
	var sustains:SustainPartMeta;
	// not all styles will have them
	var ?splashes:NotePartMeta;
	var ?holdcovers:NotePartMeta;
}