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
}