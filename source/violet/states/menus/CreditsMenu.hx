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

	override function create() {
		super.create();

		var bgOverlay = new NovaSprite();
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
			var title:NovaText = new NovaText(0, 0, 0, credit.title, 32);

			title.y = creditObjectMaxY;
			creditObjectMaxY += title.height * 1.1;

			creditObjects.add(title);

			for (contrib in credit.contributors) {
                contributors.push(contrib);
				var contribText:NovaText = new NovaText(0, 0, 0, contrib.name, 16);

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

                    if (contrib.icon_scale?.x != null) contribIcon.scale.x = contrib.icon_scale.x;
                    if (contrib.icon_scale?.y != null) contribIcon.scale.y = contrib.icon_scale.y;

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

	override function update(_:Float) {
		super.update(_);

		for (obj in creditObjects.members) {
			obj.y -= 16;

            if (Std.isOfType(obj, NovaText))
            {
                obj.color = FlxColor.WHITE;
                if (sel == obj.ID)
                obj.color = FlxColor.YELLOW;
            }

			if (obj.y < FlxG.camera.y - obj.height * 2) {
				obj.y = creditObjectMaxY + FlxG.height;
			}
		}

        if (FlxG.keys.anyJustReleased([UP, W])) sel--;
        if (FlxG.keys.anyJustReleased([DOWN, S])) sel++;

        if (sel < 0) sel = 0;
        if (sel >= contributors.length - 1) sel = contributors.length - 1;
	}
}
