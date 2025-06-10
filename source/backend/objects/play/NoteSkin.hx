package backend.objects.play;

typedef SplashSkin = {
    var name:String;
}

typedef SkinOffsets = {
    var confirm:Array<Float>;
    var sustains:Array<Float>;
    var statics:Array<Float>;
    var notes:Array<Float>;
    var pressed:Array<Float>;
    var splashes:Array<Float>;
}

typedef NoteSkin = {
    var offsets:SkinOffsets;
    var splashSkin:SplashSkin;
}