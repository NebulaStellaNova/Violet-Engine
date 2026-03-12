package violet.ui.freeplay;

import violet.data.song.Song;
import violet.backend.shaders.GaussianBlurShader;
import violet.backend.objects.special_thanks.GenzuSprite;
import flixel.group.FlxSpriteGroup;

class Capsule extends FlxSpriteGroup {
	public var icon:GenzuSprite;
	public var capsule:GenzuSprite;
	public var bpmText:GenzuSprite;
	public var difficultyText:GenzuSprite;

	public var bpmNumbers:Array<CapsuleNumber> = [];
	public var weekNumbers:Array<CapsuleNumber> = [];
	public var difficultyNumbers:Array<CapsuleNumber> = [];

	var textGroup:FlxTypedSpriteGroup<NovaText>;
	var iconGroup:FlxTypedSpriteGroup<GenzuSprite>;
	var blur = new GaussianBlurShader(1);

	static final GLOW_COLOR = 0xFF00ccff;

	public function new(song:Song) {
		super();

		capsule = new GenzuSprite(0, 0, Paths.image("menus/freeplay/capsule/freeplayCapsule"));
		capsule.addAnim("idle", "mp3 capsule w backing NOT SELECTED", [], [5, 0], 24, true);
		capsule.addAnim("selected", "mp3 capsule w backing0", [], null, 24, true);
		capsule.playAnim("idle");
		add(capsule);

		bpmText = new GenzuSprite(110, 95, Paths.image("menus/freeplay/capsule/text/bpmtext"));
		bpmText.updateHitbox();
		bpmText.scale.set(1.1, 1.1);
		add(bpmText);

		difficultyText = new GenzuSprite(460, 95, Paths.image("menus/freeplay/capsule/text/difficultytext"));
		difficultyText.updateHitbox();
		difficultyText.scale.set(1.1, 1.1);
		add(difficultyText);

		for (i in 0...2) {
			var num:CapsuleNumber = new CapsuleNumber(505 + (i * 40), 26, true, 0);
			add(num);

			difficultyNumbers.push(num);
		}

		for (i in 0...3) {
			var num:CapsuleNumber = new CapsuleNumber(155 + (i * 14), 92, false, 0);
			add(num);

			bpmNumbers.push(num);
		}

		textGroup = new FlxTypedSpriteGroup<NovaText>(0, 0);

		var glowText = new NovaText(0, 0, null, song.displayName, 40);
		glowText.setFont(Paths.font("5by7"));
		glowText.updateHitbox();
		glowText.x += 120;
		glowText.y += 42;
		glowText.color = GLOW_COLOR;
		glowText.shader = blur;
		textGroup.add(glowText);

		var mainText = new NovaText(0, 0, null, song.displayName, 40);
		mainText.setFont(Paths.font("5by7"));
		mainText.updateHitbox();
		mainText.x += 120;
		mainText.y += 42;
		textGroup.add(mainText);

		add(textGroup);

		iconGroup = new FlxTypedSpriteGroup<GenzuSprite>(0, 0);

		icon = new GenzuSprite(30, 30, Paths.image('menus/freeplay/icons/${song.icon}'));
		icon.scale.set(2.5, 2.5);
		icon.pixelPerfectRender = true;
		icon.antialiasing = false;
		icon.addAnim("idle", "idle", [], null, 24, true);
		icon.addAnim("confirm", "confirm", [], null, 12, false);
		icon.playAnim("idle");
		iconGroup.add(icon);

		add(iconGroup);
	}

	public function setSelected(selected:Bool) {
		capsule.playAnim(selected ? "selected" : "idle");
		textGroup.alpha = selected ? 1 : 0.6;
	}

	public function playConfirm() {

		icon.playAnim("confirm", true);
	}

	public function updateRatingForDiff(song:Song, diffName:String) {
		var rating:Int = 0;
		if (song._data?.ratings != null) {
			var r = Reflect.field(song._data.ratings, diffName);
			if (r != null)
				rating = Std.int(r);
		}
		updateDiffRating(rating);
	}

	public function updateDiffRating(newRating) {
		for (i in 0...difficultyNumbers.length) {
			switch (i) {
				case 0:
					if (newRating < 10) {
						difficultyNumbers[i].digit = 0;
					} else {
						difficultyNumbers[i].digit = Math.floor(newRating / 10);
					}
				case 1:
					difficultyNumbers[i].digit = newRating % 10;
				default:
					trace("Uhhh... how'd we get here??");
			}
		}
	}

	public function updateBPM(bpm:Int) {
		for (i in 0...bpmNumbers.length) {
			switch (i) {
				case 0:
					bpmNumbers[i].digit = bpm < 100 ? 0 : Math.floor(bpm / 100);
				case 1:
					bpmNumbers[i].digit = bpm < 10 ? 0 : Math.floor((bpm % 100) / 10);
				case 2:
					bpmNumbers[i].digit = bpm % 10;
				default:
					trace("Uhhh... how'd we get here again??");
			}
		}
	}
}

class CapsuleNumber extends GenzuSprite {
	public var digit(default, set):Int = 0;

	function set_digit(val):Int {
		playAnim(numToString[val], true);
		centerOffsets(false);
		switch (val) {
			case 1:
				offset.x -= 4;
			case 3:
				offset.x -= 1;
			case 6:
			case 4:
			case 9:
			default:
				centerOffsets(false);
		}
		return val;
	}

	public var baseY:Float = 0;
	public var baseX:Float = 0;

	var numToString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];

	public function new(x, y, big:Bool = false, ?initDigit:Int = 0) {
		super(x, y);
		if (big) {
			loadSprite(Paths.image("menus/freeplay/capsule/numbers/bignumbers"));
		} else {
			loadSprite(Paths.image("menus/freeplay/capsule/numbers/smallnumbers"));
		}
		for (i in 0...10) {
			var stringNum:String = numToString[i];
			addAnim(stringNum, stringNum, [], null, 24, false);
		}
		this.digit = initDigit;
		playAnim(numToString[initDigit], true);
		scale.set(1.2, 1.2);
		updateHitbox();
	}
}
