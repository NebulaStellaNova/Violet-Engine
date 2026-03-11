import openfl.filters.GlowFilter;
import violet.data.song.SongRegistry;
import violet.states.PlayState;

static var curSelected:Int = 0;
static var curSelectedDiff:Int = 0;
static var curSelectedVar:Int = 0;
var canSelect:Bool = true;
var daCapsules:Array<FlxTypedSpriteGroup> = [];
var camHUD:FlxCamera;
var capsule:GenzuSprite;
var backingCard:GenzuSprite;
var backingImage:GenzuSprite;
var angleMaskShader:AngleMask = new AngleMask();
var screenshot:GenzuSprite;
var blur = new GaussianBlurShader(1);
var glowColor = 0xFF00ccff;
var xPos = 315; // For Capsule
var black:GenzuSprite;
var diffSprite:GenzuSprite;
var freeplayText:NovaText;
var ostText:NovaText;
var spacing = 145;
var instTimer = new FlxTimer();

function create() {
	camHUD = new FlxCamera();
	camHUD.bgColor = FlxColor.TRANSPARENT;
	camHUD.zoom = 0.8;
	FlxG.cameras.add(camHUD, false);

	backingImage = new GenzuSprite(0, 0, Paths.image("menus/freeplay/freeplayBGweek1-bf"));
	backingImage.cameras = [camHUD];
	backingImage.setGraphicSize(FlxG.width / 0.8);
	backingImage.updateHitbox();
	backingImage.screenCenter(Y);
	backingImage.x = -backingImage.width - 150;
	backingImage.shader = angleMaskShader;

	backingCard = new GenzuSprite(0, 0, Paths.image("menus/freeplay/backingCard/pinkBack"));
	backingCard.cameras = [camHUD];
	backingCard.setGraphicSize(FlxG.width / 0.8, FlxG.height / 0.8);
	backingCard.scale.x = backingCard.scale.y;
	backingCard.scale.x = backingCard.scale.y *= 1.1;
	backingCard.x = -backingCard.width;
	backingCard.updateHitbox();
	backingCard.screenCenter(Y);
	backingCard.color = 0xFFFFD863;

	black = new GenzuSprite().makeGraphic(FlxG.width * 1.5, 165, FlxColor.BLACK);
	black.camera = camHUD;
	black.screenCenter(X);
	black.updateHitbox();
	black.y -= 300;

	add(backingImage);
	add(backingCard);

	diffSprite = new GenzuSprite(0, 0, Paths.image("menus/freeplay/difficulties/easy"));
	diffSprite.scale.set(1.3, 1.3);
	diffSprite.camera = camHUD;
	add(diffSprite);

	selector1 = new GenzuSprite(-250, 10, Paths.image("menus/freeplay/difficulties/selector"));
	selector1.scale.set(1.28, 1.28);
	selector1.addAnim("pressed", "arrow pointer loop", [], null, 24, true);
	selector1.playAnim("pressed");
	selector1.camera = camHUD;

	selector2 = new GenzuSprite(-250, selector1.y, Paths.image("menus/freeplay/difficulties/selector"));
	selector2.scale.set(1.28, 1.28);
	selector2.addAnim("pressed", "arrow pointer loop", [], null, 24, true);
	selector2.playAnim("pressed");
	selector2.camera = camHUD;
	selector2.flipX = true;

	freeplayText = new NovaText(-145, -150, null, "FREEPLAY", 60);
	freeplayText.setFont(Paths.font("vcr.ttf"));
	freeplayText.updateHitbox();
	freeplayText.camera = camHUD;

	ostText = new NovaText(0, -150, null, "OFFICIAL OST", 60);
	ostText.setFont(Paths.font("vcr.ttf"));
	ostText.x = FlxG.width - ostText.width / 2 + 150;
	ostText.updateHitbox();
	ostText.camera = camHUD;

	FlxTween.tween(backingCard, {x: -160}, 1, {ease: FlxEase.expoOut});
	FlxTween.tween(backingImage, {x: 315}, 1, {ease: FlxEase.expoOut, startDelay: 0.1});
	FlxTween.tween(black, {y: -175}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.2});
	FlxTween.tween(selector2, {x: 260}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.3});
	FlxTween.tween(selector1, {x: -130}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.4});
	FlxTween.tween(diffSprite, {x: -13.4285714285714}, 0.7, {ease: FlxEase.expoOut, startDelay: 0.5});
	FlxTween.tween(freeplayText, {y: -78}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.6});
	FlxTween.tween(ostText, {y: -78}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.7});

	for (i => song in SongRegistry.songs) {
		var yOffset = 10;
		var startY = (FlxG.height / 2) + spacing * (i - 0) - spacing + yOffset;
		var capsuleGroup = new FlxTypedSpriteGroup(-1000, startY);

		capsuleGroup.cameras = [camHUD];

		capsule = new GenzuSprite(0, 0, Paths.image("menus/freeplay/capsule/freeplayCapsule"));
		capsule.addAnim("idle", "mp3 capsule w backing NOT SELECTED", [], null, 24, true);
		capsule.addAnim("selected", "mp3 capsule w backing0", [], null, 24, true);
		capsule.addAnim("confirm", "mp3 capsule w backing NOT SELECTED", [], null, 24, true);
		capsule.cameras = [camHUD];

		capsuleGroup.add(capsule);

		add(capsuleGroup);
		daCapsules.push(capsuleGroup);

		var textGroup = new FlxTypedSpriteGroup(0, 0);
		var txt = new NovaText(0, 0, null, song.displayName, 40);
		txt.setFont(Paths.font("5by7"));
		txt.updateHitbox();
		txt.x += 120;
		txt.y += 42;
		txt.color = glowColor;
		txt.shader = blur;
		textGroup.add(txt);

		var txt2 = new NovaText(0, 0, null, song.displayName, 40);
		txt2.setFont(Paths.font("5by7"));
		txt2.updateHitbox();
		txt2.x += 120;
		txt2.y += 42;
		textGroup.add(txt2);

		var iconGroup = new FlxTypedSpriteGroup(0, 0);
		var icon = new GenzuSprite(30, 30, Paths.image('menus/freeplay/icons/${song.icon}'));
		icon.scale.set(2.5, 2.5);
		icon.pixelPerfectRender = true;
		icon.antialiasing = false;
		icon.addAnim("idle", "idle", [], null, 24, true);
		icon.addAnim("confirm", "confirm", [], null, 12, false);
		icon.playAnim('idle');
		iconGroup.add(icon);

		capsuleGroup.add(textGroup);
		capsuleGroup.add(iconGroup);
	}

	xPos = 315;

	add(black);
	add(selector1);
	add(selector2);
	add(freeplayText);
	add(ostText);

	playInst();
	changeSelection(0);
	changeDiff(0, true);
}

function update() {
	if (Controls.back && canSelect)
		exit();

	if (Controls.uiUp && canSelect) {
		NovaUtils.playMenuSFX(NovaUtils.SCROLL);
		changeSelection(-1);
		changeDiff(0);
	}

	if (Controls.uiDown && canSelect) {
		NovaUtils.playMenuSFX(NovaUtils.SCROLL);
		changeSelection(1);
		changeDiff(0);
	}

	if (Controls.uiLeft && canSelect) {
		changeDiff(-1);
		NovaUtils.playMenuSFX(NovaUtils.SCROLL);

		selector1.x -= 10;
		FlxTween.cancelTweensOf(selector1);
		FlxTween.tween(selector1, {x: -130}, 0.5, {ease: FlxEase.expoOut});
	}

	if (Controls.uiRight && canSelect) {
		changeDiff(1);
		NovaUtils.playMenuSFX(NovaUtils.SCROLL);

		selector2.x += 10;
		FlxTween.cancelTweensOf(selector2);
		FlxTween.tween(selector2, {x: 260}, 0.5, {ease: FlxEase.expoOut});
	}

	if (Controls.accept && canSelect) {
		playSong(SongRegistry.songs[curSelected].id, SongRegistry.songs[curSelected].difficulties[curSelectedDiff]);
	}
}

function changeSelection(amnt) {
	var yOffset = 10;
	curSelected = FlxMath.wrap(curSelected + amnt, 0, SongRegistry.songs.length - 1);
	var song = SongRegistry.songs[curSelected].id;
	for (i => capsule in daCapsules) {
		var capsuleSprite = capsule.members[0];
		capsuleSprite.playAnim(curSelected == i ? "selected" : "idle");
		var text = capsule.members[1];
		text.alpha = curSelected == i ? 1 : 0.6;
		FlxTween.cancelTweensOf(capsule);

		var distance = Math.abs(i - curSelected);
		var delay = amnt == 0 ? 0.4 + (distance * 0.09) : 0.0;

		if (curSelected < i) {
			var xOffset = i == curSelected + 1 ? 0 : (i - curSelected) * 50;
			FlxTween.tween(capsule, {x: xPos - xOffset, y: (FlxG.height / 2) + spacing * (i - curSelected) - spacing + yOffset}, 0.5,
				{ease: FlxEase.expoOut, startDelay: delay});
		} else if (curSelected == i) {
			FlxTween.tween(capsule, {x: xPos, y: (FlxG.height / 2) - spacing + yOffset}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
		} else if (curSelected > i) {
			if (i == curSelected - 2) {
				FlxTween.tween(capsule, {x: xPos + ((i - curSelected) * 50), y: -300 + yOffset}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
			} else {
				FlxTween.tween(capsule, {x: xPos + ((i - curSelected) * 50), y: (FlxG.height / 2) + spacing * (i - curSelected) - spacing + yOffset}, 0.5,
					{ease: FlxEase.expoOut, startDelay: delay});
			}
		}
	}
	playInst();
}

function playInst() {
	var inst = Paths.inst(SongRegistry.songs[curSelected].id);
	instTimer.cancel();
	instTimer = new FlxTimer().start(0.8, () -> {
		FlxG.sound.playMusic(inst, 0.8);
	});
}

function changeDiff(?amnt, ?first:Bool) {
	var song = SongRegistry.songs[curSelected];
	curSelectedDiff = FlxMath.wrap(curSelectedDiff + amnt, 0, song.difficulties.length - 1);
	if (curSelectedDiff >= SongRegistry.songs[curSelected].difficulties.length)
		curSelectedDiff = 0;
	diffSprite.loadGraphic(Paths.image('menus/freeplay/difficulties/${song.difficulties[curSelectedDiff]}'));
	diffSprite.y = selector1.y + (selector1.height / 2) - (diffSprite.height / 2);
	if (first)
		diffSprite.x = -FlxG.width;
}

function playSong(?id:String, ?difficulty:String, ?variation:String) {
	canSelect = false;
	var selectedCapsule = daCapsules[curSelected].members[0];
	selectedCapsule.playAnim("confirm", true);

	var iconGroup:FlxTypedSpriteGroup = cast daCapsules[curSelected].members[2];
	var icon:GenzuSprite = cast iconGroup.members[0];
	icon.playAnim("confirm", true);

	NovaUtils.playMenuSFX(NovaUtils.CONFIRM);
	FlxTimer.wait(1, () -> {
		camHUD.fade(FlxColor.BLACK, 0.5, false, () -> {
			FlxTimer.wait(0.5, () -> {
				PlayState.loadSong(id, difficulty);
			});
		});
	});
}

function exit() {
	NovaUtils.playMenuSFX(NovaUtils.CANCEL);

	if (canSelect == false)
		return;

	canSelect = false;

	FlxTween.cancelTweensOf(ostText);
	FlxTween.cancelTweensOf(freeplayText);
	FlxTween.cancelTweensOf(diffSprite);
	FlxTween.cancelTweensOf(selector1);
	FlxTween.cancelTweensOf(selector2);
	FlxTween.cancelTweensOf(black);
	FlxTween.cancelTweensOf(backingImage);
	FlxTween.cancelTweensOf(backingCard);

	FlxTween.tween(ostText, {y: -150}, 0.5, {ease: FlxEase.expoIn});
	FlxTween.tween(freeplayText, {y: -150}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.1});
	FlxTween.tween(diffSprite, {x: -FlxG.width}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
	FlxTween.tween(selector1, {x: -250}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.3});
	FlxTween.tween(selector2, {x: -250}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.3});
	FlxTween.tween(black, {y: -300}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.4});
	FlxTween.tween(backingImage, {x: -backingImage.width - 160}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.5});
	FlxTween.tween(backingCard, {x: -backingCard.width - 160}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.6});

	var origin = curSelected - 1;

	for (i => capsuleGroup in daCapsules) {
		FlxTween.cancelTweensOf(capsuleGroup);
		var distance = Math.abs(i - origin);
		FlxTween.tween(capsuleGroup, {x: -1000}, 0.6, {
			ease: FlxEase.expoIn,
			startDelay: 0.2 + (distance * 0.05)
		});
	}
	new FlxTimer().start(1.3, (_) -> {
		close();
	});
}
