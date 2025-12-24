package violet.states.menus;

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

	override function create() {
		super.create();

		creditObjects = new FlxTypedGroup<FlxSprite>();
		add(creditObjects);

		try {
			creditsJSON = Json.parse(FileUtil.getFileContent(Paths.json('config/credits', 'data')));
		} catch (e) {
			trace(e.message);
		}

		for (credit in creditsJSON.credits) {
			var title:NovaText = new NovaText(0, 0, 0, credit.title, 32);

			title.y = creditObjectMaxY;
			creditObjectMaxY += title.height * 1.1;

			creditObjects.add(title);

			for (contrib in credit.contributors) {
				var contribText:NovaText = new NovaText(0, 0, 0, contrib.name, 16);

				if (contrib.role != null)
					contribText.text += ' : ${contrib.role}';

				contribText.y = creditObjectMaxY;
				creditObjectMaxY += contribText.height;

				creditObjects.add(contribText);

				if (contrib.icon != null || contrib.https_icon != null) {
					var contribIcon:NovaSprite = new NovaSprite(0, creditObjectMaxY);

					creditObjectMaxY += contribIcon.height;

					if (contrib.icon != null && contrib.https_icon == null)
						contribIcon.loadSprite(Paths.image(contrib.icon, 'menus/creditsmenu'));
					if (contrib.icon == null && contrib.https_icon != null)
						contribIcon.loadSprite(contrib.https_icon);

					contribIcon.updateHitbox();
					contribIcon.scale.set(16 / contribIcon.width, 16 / contribIcon.height);
					contribIcon.updateHitbox();

					creditObjects.add(contribIcon);

					contribText.x += contribIcon.width * 1.1;
					contribText.y += contribIcon.height / 2;
				}
			}
		}

		for (obj in creditObjects.members) {
			obj.scrollFactor.set();
		}

		trace('menuedCredits');
	}

	override function stepHit(curStep:Int) {
		super.stepHit(curStep);

		for (obj in creditObjects.members) {
			obj.y -= obj.height / 4;

			if (obj.y < FlxG.camera.y - obj.height * 2) {
				obj.y = creditObjectMaxY;
			}
		}
	}
}
