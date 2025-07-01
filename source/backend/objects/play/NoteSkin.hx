package backend.objects.play;

typedef SplashSkin = {
	var name:String;
}
typedef HoldCoverSkin = {
	var name:String;
}

typedef HoldCoverOffsets = {
	var global:Array<Float>;
	var start:Array<Float>;
	var hold:Array<Float>;
	var end:Array<Float>;
}
typedef SkinOffsets = {
	var global:Array<Float>;
	var confirm:Array<Float>;
	var sustains:Array<Float>;
	var statics:Array<Float>;
	var notes:Array<Float>;
	var pressed:Array<Float>;
	var splashes:Array<Float>;
	var covers:HoldCoverOffsets;
}

typedef NoteSkin = {
	var offsets:SkinOffsets;
	var splashSkin:SplashSkin;
	var holdCoverSkin:HoldCoverSkin;

	/* New Stuff */
	var animations:AnimationList;
}

typedef AnimationList = {
	var note:NoteList;
	var strum:StrumList;
}

typedef StrumList = {
	var assetPath:String;
	var idle:BaseNote;
	var pressed:BaseNote;
	var confirm:BaseNote;
	//var sustain;
}

typedef NoteList = {
	var base:BaseNote;
	//var sustain;
}

typedef BaseNote = {
	var global:NoteGlobal;
	var left:BaseAnimation;
	var down:BaseAnimation;
	var up:BaseAnimation;
	var right:BaseAnimation;
}

typedef NoteGlobal = {
	var assetPath:String;
	var offsets:Array<Float>;
}

typedef BaseAnimation = {
	var prefix:String;
	var offsets:Array<Float>;
}

typedef BaseSustain = {
	var global:SustainGlobal;
	var left:BaseAnimation;
	var down:BaseAnimation;
	var up:BaseAnimation;
	var right:BaseAnimation;
}

typedef SustainGlobal = {
	var assetPath:String;
	var offsets:Array<Float>;
}