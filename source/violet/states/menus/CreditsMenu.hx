package violet.states.menus;

import violet.backend.EditorListBackend;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.data.credits.CreditsEntry;

class CreditsMenu extends EditorListBackend {


	override public function new() {
		super([
			{ title: "Nebula S. Nova", description: "Main Coder / Main Menu Theme" },
			{ title: "Rodney", description: "Secondary Coder" },
			{ title: "GENZU", description: "Coded The Freeplay Menu" }
		], false, true);
	}

	override function create() {
		super.create();

		FlxG.state.persistentDraw = true;
		FlxG.state.persistentUpdate = true;

	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
