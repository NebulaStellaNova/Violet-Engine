package violet.backend.objects.freeplay;

import flixel.text.FlxText;
import violet.backend.utils.ParseUtil.ParseColor;
import violet.backend.shaders.OutlineExtractionShader;
import violet.data.icon.HealthIcon;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import violet.data.song.Song;
import flixel.addons.effects.FlxSkewedSprite;

class Capsule extends FlxSpriteGroup {

	public var capsuleBackground:NovaSprite;
	public var backCase:FlxSkewedSprite;
	public var frontCase:FlxSkewedSprite;
	public var blackGradient:FlxSkewedSprite;

	override public function new(songData:Song) {
		super();

		if (songData?.customValues?.gradient != null)
			songData._data.gradient = cast songData?.customValues?.gradient;


		var gradient:Array<ParseColor> = songData._data.gradient != null ? songData._data.gradient : [songData._data.color, songData._data.color];
		var capsuleBG:String = songData._data.freeplayCapsule ?? songData?.customValues?.capsuleBackground;

		var capsulePath = Paths.image("menus/freeplaymenu/capsuleBackgrounds/" + capsuleBG) != '' ?
						  Paths.image("menus/freeplaymenu/capsuleBackgrounds/" + capsuleBG) :
						  Paths.image("menus/freeplaymenu/capsuleBackgrounds/mainStage");

		capsuleBackground = new NovaSprite().loadSprite(capsulePath, false);
		capsuleBackground.drawFrame();
		skewPixels(capsuleBackground, 30, 0);

		backCase = new FlxSkewedSprite(0, 0);
		backCase.makeGraphic(FlxG.width, 85, gradient[0]);
        backCase.antialiasing = true;
        backCase.skew.set(-30, 0);
        add(backCase);

        frontCase = new FlxSkewedSprite(15, 0);
		frontCase.makeGraphic(FlxG.width, 85, FlxColor.WHITE);
        frontCase.antialiasing = true;
		frontCase.drawFrame();
        frontCase.skew.set(-30, 0);
        add(frontCase);

		frontCase.stamp(capsuleBackground, -50, 0);

		blackGradient = new FlxSkewedSprite(15, 0);
		blackGradient.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(frontCase.width/2), Math.round(frontCase.height), [FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 0).pixels);
        blackGradient.antialiasing = true;
        blackGradient.skew.set(-30, 0);
        blackGradient.alpha = 0.6;
        add(blackGradient);

		var iconBG = new FlxSkewedSprite(27, 8);
		iconBG.makeGraphic(68, 68, gradient[0]);
        iconBG.antialiasing = true;
        iconBG.skew.set(-30, 0);
        add(iconBG);

		var iconImage = new HealthIcon(songData.icon);
        iconImage.scaleOffset = 0.5;
		iconImage.globalOffset.set(0, 0);
		iconImage.canDance = false;
        iconImage.flipX = !iconImage.flipX;
        iconImage.updateHitbox();
        iconImage.x = 45;
        iconImage.y = 5;
		iconImage.x -= iconImage._data.freeplayOffsets[0] ?? 0;
		iconImage.y -= iconImage._data.freeplayOffsets[1] ?? 0;
		iconImage.shader = new OutlineExtractionShader();
		add(iconImage);

		var displayNameText = new FlxText(0, 0, 0, songData.displayName);
	    displayNameText.setFormat(Paths.font("akira", null, "otf"), 90, FlxColor.BLACK, "center");
        displayNameText.scale.set(0.3, 0.5);
        displayNameText.drawFrame();
        displayNameText.updateHitbox();

        var displayNameSprite = new FlxSkewedSprite(iconBG.x + iconBG.width + 20, 0);
		displayNameSprite.loadGraphic(displayNameText.pixels);
        displayNameSprite.antialiasing = true;
        displayNameSprite.scale.set(0.3, 0.5);
        displayNameSprite.skew.set(-30, 0);
        add(displayNameSprite);

		var amt = displayNameText.width / (FlxG.width/2.5);
		var displayNameGradient:Array<FlxColor> = [gradient[0], FlxColor.interpolate(gradient[0], gradient[1], amt)];

        FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Math.round(displayNameSprite.width), Math.round(displayNameSprite.height), displayNameGradient, 1, 0), displayNameSprite, displayNameSprite);
		displayNameSprite.updateHitbox();

		var composerText = new FlxText(0, 0, 0, songData._data.composer != null ? songData._data.composer : "Unknown Artist");
	    composerText.setFormat(Paths.font("bozon", null, "otf"), 40, FlxColor.BLACK, "center");
        composerText.drawFrame();
        composerText.updateHitbox();

        var composerSprite = new FlxSkewedSprite(displayNameSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        composerSprite.loadGraphic(composerText.pixels);
        composerSprite.antialiasing = true;
        composerSprite.scale.set(0.5, 0.5);
        composerSprite.skew.set(-30, 0);
        composerSprite.updateHitbox();

        var composerSegment = new FlxSkewedSprite(composerSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        composerSegment.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(composerSprite.width + 20), 30, [FlxColor.WHITE, FlxColor.WHITE], 1, 0).pixels);
        composerSegment.antialiasing = true;
        composerSegment.skew.set(-30, 0);
        add(composerSegment);
        add(composerSprite);

		var composerAmt = composerSegment.width / (FlxG.width/2.5);
		var composerGradient:Array<FlxColor> = [gradient[0], FlxColor.interpolate(gradient[0], gradient[1], composerAmt)];

        FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Math.round(composerSegment.width), Math.round(composerSegment.height), composerGradient, 1, 0), composerSegment, composerSegment);

		var bpmText = new FlxText(0, 0, 0, "BPM: " + songData.bpm);
	    bpmText.setFormat(Paths.font("bozon", null, "otf"), 40, FlxColor.BLACK, "center");
        bpmText.drawFrame();
        bpmText.updateHitbox();

        var bpmSprite = new FlxSkewedSprite(composerSegment.x + composerSegment.width + 20, displayNameSprite.y + displayNameSprite.height - 3);
        bpmSprite.loadGraphic(bpmText.pixels);
        bpmSprite.antialiasing = true;
        bpmSprite.scale.set(0.5, 0.5);
        bpmSprite.skew.set(-30, 0);
        bpmSprite.updateHitbox();

        var bpmSegment = new FlxSkewedSprite(bpmSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        bpmSegment.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(bpmSprite.width + 20), 30, [FlxColor.WHITE, FlxColor.WHITE], 1, 0).pixels);
        bpmSegment.antialiasing = true;
        bpmSegment.skew.set(-30, 0);
        add(bpmSegment);
        add(bpmSprite);

		var bpmAmt = bpmSegment.width / (FlxG.width/2.5);
		var bpmGradient:Array<FlxColor> = [FlxColor.interpolate(gradient[0], gradient[1], composerAmt), FlxColor.interpolate(gradient[0], gradient[1], composerAmt + bpmAmt)];
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Math.round(bpmSegment.width), Math.round(bpmSegment.height), bpmGradient, 1, 0), bpmSegment, bpmSegment);
	}


	function skewPixels(sprite:NovaSprite, xSkew:Float = 0, ySkew:Float = 0) {
		var skewXDegrees:Float = xSkew;
        var skewYDegrees:Float = ySkew;

        var skewXRad:Float = skewXDegrees * (Math.PI / 180);
        var skewYRad:Float = skewYDegrees * (Math.PI / 180);

        var matrix:Matrix = new Matrix();
        matrix.c = Math.tan(skewXRad);
        matrix.b = Math.tan(skewYRad);

        var originalPixels:BitmapData = sprite.graphic.bitmap;

        var newWidth:Int = Std.int(originalPixels.width + (originalPixels.height * Math.abs(matrix.c)));
        var newHeight:Int = Std.int(originalPixels.height + (originalPixels.width * Math.abs(matrix.b)));

        if (matrix.c < 0) matrix.tx = -originalPixels.height * matrix.c;
        if (matrix.b < 0) matrix.ty = -originalPixels.width * matrix.b;
		var skewedPixels:BitmapData = new BitmapData(newWidth, newHeight, true, 0x00FFFFFF);
        skewedPixels.draw(originalPixels, matrix, null, null, null, false);
        sprite.loadGraphic(skewedPixels);
	}
}