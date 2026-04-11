package violet.states.menus;

import violet.backend.EditorListBackend;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.data.credits.CreditsEntry;

class CreditsMenu extends EditorListBackend {

	public var entries:Array<CreditsEntry> = [];
	public var contributorList:Array<CreditsContributor> = [];

	override public function new() {
		var out:Array<EditorListOption> = [];
		entries = ParseUtil.jsonOrYaml([Paths.ASSETS_FOLDER, 'data/config/credits'].join('/'), 'root');

		for (i in ModdingAPI.getActiveMods()) {
			var modEntries = ParseUtil.jsonOrYaml([ModdingAPI.MOD_FOLDER, i.folder, 'data/config/credits'].join('/'), 'root', 'null');
			if (modEntries != null) {
				var modEntriesOut:Array<CreditsEntry> = cast modEntries;
				entries = entries.concat(modEntriesOut);
			}
		}

		for (i in entries) {
			out.push({ title: i.title, skip: true });
			contributorList.push({ name: '' });
			for (contributor in i.contributors) {
				contributorList.push(contributor);
				out.push({ title: contributor.name, description: contributor.role, bold: false });
			}
			out.push({ title: '', skip: true });
			contributorList.push({ name: '' });
		}
		super(out, false, true);
	}

	override function create() {
		super.create();

		FlxG.state.persistentDraw = true;
		FlxG.state.persistentUpdate = true;

		for (i=>item in items) {
			var data = contributorList[i];
			if (data?.icon != null) {
				var icon = new NovaSprite(Paths.image('menus/creditsmenu/icons/${data.icon}'));
				icon.setGraphicSize(100, 100);
				item.add(icon);
				item.extra.set('icon', icon);
				item.offsetX = 55;
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		for (i=>item in items) {
			var icon:NovaSprite = item.extra.get('icon');
			if (icon != null) {
				icon.x = item.x - 55;
				icon.y = item.y - 15;
				icon.alpha = item.alpha;
			}
		}

		if (Controls.back) {
			if (Std.isOfType(_parentState, MainMenu)) FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5, { ease: FlxEase.quadInOut });
		}
	}

}
