package violet.backend.objects.freeplay;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import violet.data.icon.HealthIcon;
import violet.data.level.Level;

using violet.backend.utils.MathUtil;

class LevelCapsule extends Capsule {

	public var collasped:Bool = true;

	public var hidden(get, never):Bool;
	function get_hidden():Bool {
		for (song in children)
			if (!song.hidden)
				return false;
		return collasped = true;
	}
	public function isFav():Bool {
		for (song in children)
			if (song.hidden)
				continue;
			else if (!song.data.isFavorited)
				return false;
		return true;
	}

	public var data:Level;
	// to keep track of its sub items / songs
	public final children:Array<SongCapsule> = [];

	public var heart:NovaSprite;

	override public function new(data:Level) {
		super();
		this.data = data;
	}

	override public function init():Void {
		super.init();

		Capsule.colorToAlphaShader.targetColor = FlxColor.BLACK;

		var capsuleBG:String = children[0].data._data.freeplayCapsule ?? children[0].data?.customValues?.capsuleBackground ?? "mainStage";

		var temp = new NovaSprite().loadSprite(Paths.image("menus/freeplaymenu/capsuleBackgrounds/" + capsuleBG));
		temp.drawFrame();
		capsuleBackground.loadGraphicFromSprite(temp);
		capsuleBackground.drawFrame();
		temp.destroy();

		backCase.makeGraphic(FlxG.width, 85, data._data.background);

		var iconScale = 0.425;
		var iconBG = new FlxSkewedSprite(-25, 8);
		iconBG.makeGraphic(Math.round(68/iconScale), Math.round(68/iconScale), data._data.background);
		iconBG.drawFrame();
		Capsule.skewPixels(iconBG, -30, 0);
		iconBG.scale.set(iconScale, iconScale);
		iconBG.updateHitbox();
		add(iconBG);

		final outlinePath = 'icons/outlines/${children[0].data.icon}';
		final outlineAsset = Paths.image(outlinePath);
		var iconImage = new HealthIcon(children[0].data.icon, false, false, outlineAsset != '' ? outlinePath : null);
		iconImage.scaleOffset = 0.45;
		iconImage.globalOffset.set(0, 0);
		iconImage.canDance = false;
		// if (iconImage._data.freeplayFlipX) iconImage.flipX = !iconImage.flipX;
		iconImage.flipX = !iconImage.flipX;
		iconImage.updateHitbox();
		iconImage.x = 45;
		iconImage.y = 5;

		iconImage.drawFrame();
		Capsule.scalePixels(iconImage, 1, 1);
		var x = (iconImage.width % 150) * 150;
		Capsule.cropPixels(iconImage, x.round(), 0, 150, 150);
		Capsule.isolateBlackPixels(iconImage);
		var offsetX = (iconImage._data.freeplayOffsets ?? [0, 0])[0] ?? 0;
		var offsetY = (iconImage._data.freeplayOffsets ?? [0, 0])[1] ?? 0;
		iconBG.stamp(iconImage, 140 + offsetX.round(), 0 + offsetY.round());
		iconBG.shader = Capsule.colorToAlphaShader;

		iconBG.updateHitbox();

		var displayNameText = new FlxText(0, 0, 0, data.getTitle());
		displayNameText.setFormat(Paths.font("akira", null, "otf"), 100, FlxColor.BLACK, "center");
		displayNameText.scale.set(0.3, 0.5);
		displayNameText.scale.scale(2);
		displayNameText.drawFrame();
		displayNameText.updateHitbox();

		var displayNameSprite = new FlxSkewedSprite(iconBG.x + iconBG.width - 5, 17);
		displayNameSprite.loadGraphic(displayNameText.pixels);
		displayNameSprite.scale.set(0.3, 0.5);
		displayNameSprite.skew.set(-30, 0);
		add(displayNameSprite);
		displayNameText.destroy();

		FlxSpriteUtil.alphaMaskFlxSprite(new FlxSprite().makeGraphic(displayNameSprite.width.round(), displayNameSprite.height.round(), data._data.background), displayNameSprite, displayNameSprite);
		displayNameSprite.updateHitbox();

		/* var composerText = new FlxText(0, 0, 0, data._data.composer != null ? data._data.composer : "Unknown Artist");
		composerText.setFormat(Paths.font("bozon", null, "otf"), 70, FlxColor.BLACK, "center");
		composerText.drawFrame();
		composerText.updateHitbox();

		var composerSprite = new FlxSkewedSprite(displayNameSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
		composerSprite.loadGraphic(composerText.pixels);
		composerSprite.scale.set(0.5, 0.5);
		composerSprite.drawFrame();
		composerSprite.updateHitbox();

		var composerSegment = new FlxSkewedSprite(composerSprite.x - 10, displayNameSprite.y + displayNameSprite.height - 3);
		composerSegment.loadGraphic(FlxGradient.createGradientFlxSprite(Math.round(composerSprite.width + 40), 30*2, [FlxColor.WHITE, FlxColor.WHITE], 1, 0).pixels);
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
		composerSegment.updateHitbox(); */

		heart = new NovaSprite(-40, -40, Paths.image('menus/freeplaymenu/categories/heart'));
		heart.alpha = isFav() ? 1 : 0;
		add(heart);
	}

	override public function toggleFavorite():Void {
		for (song in children)
			song.toggleFavorite();
	}

}