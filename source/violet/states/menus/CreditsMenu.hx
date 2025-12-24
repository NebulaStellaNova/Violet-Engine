package violet.states.menus;

import violet.data.credits.CreditsEntry.CreditsContributor;
import flixel.FlxObject;
import flixel.text.FlxText;
import violet.backend.utils.FileUtil;
import haxe.Json;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import violet.data.credits.CreditsEntry.CreditsJSON;

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
		FlxTween.tween(bgOverlay, {alpha: .2}, 1);

		creditObjects = new FlxTypedGroup<FlxSprite>();
		add(creditObjects);

		try {
			creditsJSON = Json.parse(FileUtil.getFileContent(Paths.json('config/credits', 'data')));
		} catch (e) {
			trace(e.message);
		}

		var contribI = 0;
		for (credit in creditsJSON.credits) {
			var title:NovaText = new NovaText(0, 0, FlxG.width / 2, credit.title, 32);

			title.y = creditObjectMaxY;
			creditObjectMaxY += title.height * 1.1;

			creditObjects.add(title);

			for (contrib in credit.contributors) {
				contributors.push(contrib);
				var contribText:NovaText = new NovaText(0, 0, FlxG.width / 2, contrib.name, 16);

				contribText.ID = contribI;
				contribI++;
				if (contrib.role != null)
					contribText.text += ' : ${contrib.role}';

				contribText.y = creditObjectMaxY;
				creditObjectMaxY += contribText.height;

				creditObjects.add(contribText);

				if (contrib.icon != null || contrib.https_icon != null) {
					var contribIcon:NovaSprite = new NovaSprite(0, creditObjectMaxY);

					creditObjectMaxY += contribIcon.height;

					if (contrib.icon != null && contrib.https_icon == null)
						contribIcon.loadSprite(Paths.image(contrib.icon, 'menus/creditsmenu/icons'));
					if (contrib.icon == null && contrib.https_icon != null)
						contribIcon.loadSprite(contrib.https_icon);

					if (contrib.icon_scale?.x != null)
						contribIcon.scale.x = contrib.icon_scale.x;
					if (contrib.icon_scale?.y != null)
						contribIcon.scale.y = contrib.icon_scale.y;

					contribIcon.updateHitbox();

					creditObjects.add(contribIcon);

					contribText.x += contribIcon.width * 1.1;
					contribText.y += contribIcon.height / 2;
				}
			}
		}

		for (obj in creditObjects.members) {
			obj.scrollFactor.set();
			// obj.x += 16;
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
			obj.y -= 8;

			if (Std.isOfType(obj, NovaText)) {
				obj.color = FlxColor.WHITE;
				if (sel == obj.ID)
					obj.color = FlxColor.YELLOW;
			}

			if (obj.y < FlxG.camera.y - 300) {
				obj.y = creditObjectMaxY + FlxG.height;
			}
		}

		if (Controls.uiUpReleased || Controls.uiDownReleased) {
			FlxG.sound.play(Cache.sound('menu/scroll'));

			if (Controls.uiUpReleased)
				sel--;
			if (Controls.uiDownReleased)
				sel++;

			if (sel < 0)
				sel = 0;
			if (sel >= contributors.length - 1)
				sel = contributors.length - 1;
		}

		if (Controls.back && !transitioning) {
			transitioning = true;

			FlxG.sound.play(Cache.sound('menu/cancel'), .4);
			FlxTween.tween(bgOverlay, {alpha: 0}, 1);
			for (obj in creditObjects.members)
				FlxTween.tween(obj, {alpha: 0}, 1);
		}

        if (transitioning)
        {
			FlxG.sound.play(Cache.sound('menu/scroll'), .4);
            sel--;
            if (sel < 0)
                sel = contributors.length - 1;
        }
	}

	var transitioning:Bool = false;
}
