package violet.backend.objects.freeplay;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import violet.backend.shaders.AngleCropShader;
import violet.backend.shaders.ColorToAlphaShader;
import violet.backend.shaders.OutlineExtractionShader;

using violet.backend.utils.MathUtil;

class Capsule extends FlxSpriteGroup {

	public var capsuleBackground:FlxSkewedSprite;
	public var backCase:FlxSkewedSprite;
	public var frontCase:FlxSkewedSprite;
	public var blackGradient:FlxSkewedSprite;

	public static var colorToAlphaShader:ColorToAlphaShader = new ColorToAlphaShader();
	public static var outlineExtractionShader:OutlineExtractionShader = new OutlineExtractionShader();
	public static var angleCropShader:AngleCropShader = new AngleCropShader();

	override public function new() {
		super();

		var temp = new NovaSprite(0, 0).loadSprite(Paths.image("menus/freeplaymenu/capsuleBackgrounds/mainStage"));
		temp.drawFrame();

		capsuleBackground = new FlxSkewedSprite(-10, 0);
		capsuleBackground.loadGraphicFromSprite(temp);
		capsuleBackground.drawFrame();
		// skewPixels(capsuleBackground, 30, 0);

		backCase = new FlxSkewedSprite(0, 0);
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