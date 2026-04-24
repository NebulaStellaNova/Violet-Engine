package violet.backend.objects.freeplay;

import violet.backend.shaders.AngleCropShader;
import violet.backend.shaders.AngleMask;
import violet.backend.shaders.ColorToAlphaShader;
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
import openfl.geom.Rectangle;
import openfl.geom.Point;

using violet.backend.utils.MathUtil;

class Capsule extends FlxSpriteGroup {

	// public var capsuleBackground:NovaSprite;
	public var backCase:FlxSkewedSprite;
	public var frontCase:FlxSkewedSprite;
	public var blackGradient:FlxSkewedSprite;

    public static var colorToAlphaShader:ColorToAlphaShader = new ColorToAlphaShader();
    public static var outlineExtractionShader:OutlineExtractionShader = new OutlineExtractionShader();
    public static var angleCropShader:AngleCropShader = new AngleCropShader();

	override public function new(songData:Song) {
		super();
        colorToAlphaShader.targetColor = FlxColor.BLACK;

        var capsuleWidth:Float = FlxG.width/4;

		if (songData?.customValues?.gradient != null)
			songData._data.gradient = cast songData?.customValues?.gradient;


		var gradient:Array<ParseColor> = songData._data.gradient != null ? songData._data.gradient : [songData._data.color, songData._data.color];
		var capsuleBG:String = songData._data.freeplayCapsule ?? songData?.customValues?.capsuleBackground ?? "mainStage";

        var temp = new NovaSprite(0, 0).loadSprite(Paths.image("menus/freeplaymenu/capsuleBackgrounds/" + capsuleBG));
		temp.drawFrame();

		var capsuleBackground = new FlxSkewedSprite(-10, 0);
        capsuleBackground.loadGraphicFromSprite(temp);
		capsuleBackground.drawFrame();
		// skewPixels(capsuleBackground, 30, 0);

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

        capsuleBackground.shader = angleCropShader;
        add(capsuleBackground);


		blackGradient = new FlxSkewedSprite(14, 0);
		blackGradient.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(frontCase.width/2), Math.round(frontCase.height), [FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 0).pixels);
        blackGradient.antialiasing = true;
        blackGradient.skew.set(-30, 0);
        blackGradient.alpha = 0.6;
        add(blackGradient);

        var iconScale = 0.425;
		var iconBG = new FlxSkewedSprite(-25, 8);
		iconBG.makeGraphic(Math.round(68/iconScale), Math.round(68/iconScale), gradient[0]);
        iconBG.antialiasing = true;
        iconBG.drawFrame();
        skewPixels(iconBG, -30, 0);
        iconBG.scale.set(iconScale, iconScale);
        iconBG.updateHitbox();
        add(iconBG);

		var iconImage = new HealthIcon(songData.icon, false, false);
        iconImage.scaleOffset = 0.45;
		iconImage.globalOffset.set(0, 0);
		iconImage.canDance = false;
        // if (iconImage._data.freeplayFlipX) iconImage.flipX = !iconImage.flipX;
        iconImage.flipX = !iconImage.flipX;
        iconImage.updateHitbox();
        iconImage.x = 45;
        iconImage.y = 5;

        iconImage.drawFrame();
        scalePixels(iconImage, 1, 1);
        var x = (iconImage.width % 150) * 150;
        cropPixels(iconImage, x.round(), 0, 150, 150);
        isolateBlackPixels(iconImage);
        var offsetX = (iconImage._data.freeplayOffsets ?? [0, 0])[0] ?? 0;
        var offsetY = (iconImage._data.freeplayOffsets ?? [0, 0])[1] ?? 0;
        iconBG.stamp(iconImage, 140 + offsetX.round(), 0 + offsetY.round());
        iconBG.shader = colorToAlphaShader;

        iconBG.updateHitbox();

		var displayNameText = new FlxText(0, 0, 0, songData.displayName);
	    displayNameText.setFormat(Paths.font("akira", null, "otf"), 90, FlxColor.BLACK, "center");
        displayNameText.scale.set(0.3, 0.5);
        displayNameText.drawFrame();
        displayNameText.updateHitbox();

        var displayNameSprite = new FlxSkewedSprite(iconBG.x + iconBG.width + 5, 0);
		displayNameSprite.loadGraphic(displayNameText.pixels);
        displayNameSprite.antialiasing = true;
        displayNameSprite.scale.set(0.3, 0.5);
        displayNameSprite.skew.set(-30, 0);
        add(displayNameSprite);

        var gradientMult = 2;

		var amt = displayNameText.width / capsuleWidth;
        // amt /= gradientMult;
		var displayNameGradient:Array<FlxColor> = [gradient[0], FlxColor.interpolate(gradient[0], gradient[1], amt)];

        FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(displayNameSprite.width.round(), displayNameSprite.height.round(), displayNameGradient, 1, 0), displayNameSprite, displayNameSprite);
		displayNameSprite.updateHitbox();

		var composerText = new FlxText(0, 0, 0, songData._data.composer != null ? songData._data.composer : "Unknown Artist");
	    composerText.setFormat(Paths.font("bozon", null, "otf"), 70, FlxColor.BLACK, "center");
        composerText.drawFrame();
        composerText.updateHitbox();

        var composerSprite = new FlxSkewedSprite(displayNameSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        composerSprite.loadGraphic(composerText.pixels);
        composerSprite.antialiasing = true;
        composerSprite.scale.set(0.5, 0.5);
        composerSprite.drawFrame();
        composerSprite.updateHitbox();

        var composerSegment = new FlxSkewedSprite(composerSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        composerSegment.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(composerSprite.width + 40), 30*2, [FlxColor.WHITE, FlxColor.WHITE], 1, 0).pixels);
        composerSegment.antialiasing = true;
        composerSegment.skew.set(-30, 0);
        composerSegment.scale.set(0.5, 0.5);
        composerSegment.drawFrame();
        add(composerSegment);

		var composerAmt = composerSegment.width / capsuleWidth;
        composerAmt /= gradientMult;
		var composerGradient:Array<FlxColor> = [gradient[0], FlxColor.interpolate(gradient[0], gradient[1], composerAmt)];

        FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(composerSegment.width.round(), composerSegment.height.round(), composerGradient, 1, 0), composerSegment, composerSegment);
        composerSegment.stamp(composerSprite, (-composerSegment.width/2).round() + 40, (-composerSegment.height/2).round() + 15);
        composerSegment.shader = colorToAlphaShader;
        composerSegment.updateHitbox();

		var bpmText = new FlxText(0, 0, 0, "    " + songData.bpm);
	    bpmText.setFormat(Paths.font("bozon", null, "otf"), 70, FlxColor.BLACK, "center");
        bpmText.drawFrame();
        bpmText.updateHitbox();

        var musicNote = new FlxSprite(200, 200).makeGraphic(100, 100, FlxColor.TRANSPARENT);// 1. The Note Head (the circle)
        FlxSpriteUtil.drawCircle(musicNote, 14, 30, 6, FlxColor.BLACK);
        FlxSpriteUtil.drawRect(musicNote, 18, 10, 2, 21, FlxColor.BLACK);
        FlxSpriteUtil.drawRect(musicNote, 18, 10, 12, 3, FlxColor.BLACK);

        var bpmSprite = new FlxSkewedSprite(composerSegment.x + composerSegment.width + 20, displayNameSprite.y + displayNameSprite.height - 3);
        bpmSprite.loadGraphic(bpmText.pixels);
        bpmSprite.antialiasing = true;
        bpmSprite.scale.set(0.5, 0.5);
        bpmSprite.skew.set(-30, 0);
        bpmSprite.updateHitbox();
        bpmSprite.drawFrame();


        var bpmSegment = new FlxSkewedSprite(bpmSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
        bpmSegment.loadGraphic(FlxGradient.createGradientFlxSprite(bpmSprite.width.round() + 40, 30*2, [FlxColor.WHITE, FlxColor.WHITE], 1, 0).pixels);
        bpmSegment.antialiasing = true;
        bpmSegment.skew.set(-30, 0);
        bpmSegment.scale.set(0.5, 0.5);
        add(bpmSegment);
        // add(bpmSprite);


		var bpmAmt = bpmSegment.width / capsuleWidth;
		bpmAmt /= gradientMult;
		var bpmGradient:Array<FlxColor> = [FlxColor.interpolate(gradient[0], gradient[1], composerAmt), FlxColor.interpolate(gradient[0], gradient[1], composerAmt + bpmAmt)];
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(bpmSegment.width.round(), bpmSegment.height.round(), bpmGradient, 1, 0), bpmSegment, bpmSegment);
        bpmSegment.stamp(bpmSprite, (-bpmSegment.width/2).round() + 40, (-bpmSegment.height/2).round() + 15);
        bpmSegment.stamp(musicNote, 15, 6);

        bpmSegment.shader = colorToAlphaShader;
        bpmSegment.updateHitbox();
	}


	function skewPixels(sprite:FlxSprite, xSkew:Float = 0, ySkew:Float = 0) {
		var skewXDegrees:Float = xSkew;
        var skewYDegrees:Float = ySkew;

        var skewXRad:Float = skewXDegrees * (Math.PI / 180);
        var skewYRad:Float = skewYDegrees * (Math.PI / 180);

        var sample:Int = 2;

        var matrix:Matrix = new Matrix();
        matrix.c = Math.tan(skewXRad);
        matrix.b = Math.tan(skewYRad);
        matrix.scale(sample, sample);

        var originalPixels:BitmapData = sprite.graphic.bitmap;
        var newWidth:Int = Std.int(originalPixels.width + (originalPixels.height * Math.abs(matrix.c)));
        var newHeight:Int = Std.int(originalPixels.height + (originalPixels.width * Math.abs(matrix.b)));

        if (matrix.c < 0) matrix.tx = (-originalPixels.height * matrix.c) * sample;
        if (matrix.b < 0) matrix.ty = (-originalPixels.width * matrix.b) * sample;

        var tempBD:BitmapData = new BitmapData(newWidth * sample, newHeight * sample, true, 0);
        tempBD.draw(originalPixels, matrix, null, null, null, true);

        var finalBD:BitmapData = new BitmapData(newWidth, newHeight, true, 0);
        var downscaleMatrix = new Matrix();
        downscaleMatrix.scale(1/sample, 1/sample);
        finalBD.draw(tempBD, downscaleMatrix, null, null, null, true);

        sprite.loadGraphic(finalBD);
	}

    function scalePixels(sprite:FlxSprite, scaleX:Float, scaleY:Float):Void {
        var oldPixels:BitmapData = sprite.pixels;
        var newWidth:Int = Std.int(oldPixels.width * scaleX);
        var newHeight:Int = Std.int(oldPixels.height * scaleY);
        var newPixels:BitmapData = new BitmapData(newWidth, newHeight, true, 0);
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        newPixels.draw(oldPixels, matrix, null, null, null, true);
        sprite.pixels = newPixels;
    }

    function isolateBlackPixels(sprite:FlxSprite, sensitivity:Float = 0.001):Void {
        if (sprite == null || sprite.graphic == null || sprite.graphic.bitmap == null) {
            return;
        }

        var bmd:BitmapData = sprite.pixels;

        bmd.lock();

        var color:Int;
        var r:Int, g:Int, b:Int;
        var brightness:Float;
        var transparent:Int = 0x00000000;

        for (y in 0...bmd.height) {
            for (x in 0...bmd.width) {
                color = bmd.getPixel32(x, y);

                if ((color >> 24) & 0xFF == 0) continue;

                r = (color >> 16) & 0xFF;
                g = (color >> 8) & 0xFF;
                b = color & 0xFF;

                brightness = (r + g + b) / 3;

                if (brightness > sensitivity) {
                    bmd.setPixel32(x, y, transparent);
                }
            }
        }

        bmd.unlock();

        sprite.pixels = bmd;
    }

    function cropPixels(sprite:FlxSprite, x:Int, y:Int, width:Int, height:Int):Void {
        if (sprite == null || sprite.graphic == null) return;

        var original:BitmapData = sprite.pixels;
        var cropped:BitmapData = new BitmapData(width, height, true, 0x00000000);
        var sourceRect:Rectangle = new Rectangle(x, y, width, height);
        var destPoint:Point = new Point(0, 0);
        cropped.copyPixels(original, sourceRect, destPoint);
        sprite.pixels = cropped;

        sprite.updateHitbox();
    }
}