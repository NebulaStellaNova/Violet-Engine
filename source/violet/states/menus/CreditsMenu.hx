package violet.states.menus;

import haxe.Json;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

import violet.backend.utils.FileUtil;
import violet.backend.utils.ParseUtil;
import violet.backend.utils.NovaUtils;
import violet.data.credits.CreditsEntry.CreditsJSON;
import violet.data.credits.CreditsEntry.CreditsContributor;

class CreditsMenu extends violet.backend.SubStateBackend {
	public var creditsJSON:CreditsJSON;

	public var creditObjects:FlxTypedGroup<FlxSprite>;

	var creditObjectMaxY = 0.0;

	public var contributors:Array<CreditsContributor> = [];

	public var sel:Int = 0;

	public var selectedGuy:FlxText;
	public var selectedGuyRole:FlxText;

	var bgOverlay = new NovaSprite();

	override function create() {
		super.create();

		bgOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bgOverlay);
		bgOverlay.scrollFactor.set();
		bgOverlay.alpha = 0;
		FlxTween.tween(bgOverlay, {alpha: .8}, 1);

		creditObjects = new FlxTypedGroup<FlxSprite>();
		add(creditObjects);

		try {
			creditsJSON = ParseUtil.json('config/credits', 'data');
		} catch (e) {
			trace(e.message);
		}

		var contribI = 0;
		for (credit in creditsJSON.credits) {
			var title:NovaText = new NovaText(8, 0, FlxG.width / 2 - 8, credit.title, 32);

			title.y = creditObjectMaxY;
			creditObjectMaxY += title.height * 1.1;

			creditObjects.add(title);

			for (contrib in credit.contributors) {
				contributors.push(contrib);
				var contribText:NovaText = new NovaText(16, 0, (FlxG.width / 2) - 16, contrib.name, 16);

				contribText.ID = contribI;
				contribI++;
				if (contrib.role != null)
					contribText.text += ' : ${contrib.role}';

				contribText.y = creditObjectMaxY;
				creditObjectMaxY += contribText.height;

				creditObjects.add(contribText);

				if (contrib.icon != null || contrib.https_icon != null) {
					var contribIcon:NovaSprite = new NovaSprite(contribText.x, creditObjectMaxY);

					if (contrib.icon != null && contrib.https_icon == null)
						contribIcon.loadSprite(Paths.image('menus/creditsmenu/icons/' + contrib.icon));
					if (contrib.icon == null && contrib.https_icon != null)
						contribIcon.loadSprite(contrib.https_icon);

					if (contrib.icon_scale?.x != null)
						contribIcon.scale.x = contrib.icon_scale.x;
					if (contrib.icon_scale?.y != null)
						contribIcon.scale.y = contrib.icon_scale.y;

					contribIcon.updateHitbox();

					creditObjects.add(contribIcon);

					contribText.x += contribIcon.width * 1.1;
                    // contribText.fieldWidth = ((FlxG.width / 2) - 16) - (contribIcon.width);
					contribText.y += contribIcon.height / 2;
					creditObjectMaxY += contribIcon.height;
				}
			}
		}

		for (obj in creditObjects.members) {
			obj.scrollFactor.set();
		}

		selectedGuy = new FlxText(FlxG.width / 2, 0, FlxG.width / 2, "Hi", 32);
		add(selectedGuy);
		selectedGuy.scrollFactor.set();

		selectedGuyRole = new FlxText(FlxG.width / 2, selectedGuy.y + selectedGuy.height + 16, 0, "foam", 16);
		add(selectedGuyRole);
		selectedGuyRole.scrollFactor.set();

		trace('menuedCredits');
	}

	override function update(_:Float) {
		super.update(_);

		selectedGuy.text = contributors[sel].name;
		selectedGuyRole.text = contributors[sel]?.role ?? 'N/A';
		selectedGuyRole.y = selectedGuy.y + selectedGuy.height + 16;

		for (obj in creditObjects.members) {
			obj.y -= 1 / 1000000;

			if (Std.isOfType(obj, NovaText)) {
				obj.color = FlxColor.WHITE;
				if (sel == obj.ID)
					obj.color = FlxColor.YELLOW;
			}

			if (obj.y < FlxG.camera.y - 300) {
				obj.y = creditObjectMaxY + FlxG.height;
			}
		}

        if (Controls.accept)
            if (contributors[sel].url != null)
                FlxG.openURL(contributors[sel].url);

		if (Controls.uiUp || Controls.uiDown) {
			FlxG.sound.play(Cache.sound('menu/scroll'));

			if (Controls.uiUp)
				sel--;
			if (Controls.uiDown)
				sel++;

			if (sel < 0)
				sel = 0;
			if (sel >= contributors.length - 1)
				sel = contributors.length - 1;
		}

		if (Controls.back && !transitioning) {
			transitioning = true;

			FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

			NovaUtils.playMenuSFX(NovaUtils.CANCEL);
			FlxTween.tween(bgOverlay, {alpha: 0}, 2);
			for (obj in creditObjects.members)
				FlxTween.tween(obj, {alpha: 0}, 1);
			for (obj in [selectedGuy, selectedGuyRole])
				FlxTween.tween(obj, {alpha: 0}, 1);

			FlxTimer.wait(2, () -> {
				close();
			});
		}
	}

	var transitioning:Bool = false;
}
