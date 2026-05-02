package violet.backend.objects.freeplay;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.text.FlxText;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;
import violet.backend.utils.ParseUtil;
import violet.data.icon.HealthIcon;
import violet.data.song.Song;

using violet.backend.utils.MathUtil;

class SongCapsule extends Capsule {

	// public var parentCapsule:LevelCapsule;

	override public function new(songData:Song) {
		super();

		Capsule.colorToAlphaShader.targetColor = FlxColor.BLACK;

		var capsuleWidth:Float = FlxG.width/4;

		if (songData?.customValues?.gradient != null)
			songData._data.gradient = cast songData?.customValues?.gradient;

		var gradient:Array<ParseColor> = songData._data.gradient != null ? songData._data.gradient : [songData._data.color, songData._data.color];
		var capsuleBG:String = songData._data.freeplayCapsule ?? songData?.customValues?.capsuleBackground ?? "mainStage";

		var temp = new NovaSprite(0, 0).loadSprite(Paths.image("menus/freeplaymenu/capsuleBackgrounds/" + capsuleBG));
		temp.drawFrame();

		capsuleBackground.loadGraphicFromSprite(temp);
		capsuleBackground.drawFrame();

		backCase.makeGraphic(FlxG.width, 85, gradient[0]);

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

		final outlinePath = 'icons/outlines/${songData.icon}-outline'; // Typo but I'm not changing it now
		final outlineAsset = Paths.image(outlinePath);
		var iconImage = new HealthIcon(songData.icon, false, false, outlineAsset != '' ? outlinePath : null);
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
		iconBG.shader = Capsule.colorToAlphaShader;

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
		composerSegment.shader = Capsule.colorToAlphaShader;
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

		bpmSegment.shader = Capsule.colorToAlphaShader;
		bpmSegment.updateHitbox();
	}

}