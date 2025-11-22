package violet.backend.objects;

import violet.states.*;
import violet.states.menus.*;
import violet.states.menus.substates.*;

class ClassData {
	public var type:String;
	public var target:Dynamic;
	public var isSubState:Bool = false;

	public function new(string:String) {
		this.type = string.split(":")[0];
		this.target = new MainMenu();

		if (this.type == "source") {
			switch (string.split(":")[1]) {
				case "MainMenu":
					this.target = new MainMenu();
				/* case "CreditsState":
					this.target = new CreditsState();
				case "FreeplayState":
					this.target = new FreeplayState();
				case "PlayState":
					this.target = new PlayState(); */
				// case "ModMenuSubState":
				// 	this.target = new ModMenuSubState();
				// 	this.isSubState = true;
				default:
					trace('error:Unknown State "${string.split(":")[1]}" returning to the Main Menu');
			}
		} else if (this.type == "mod") {
			trace('error:Modded States are not implemented, returning to the Main Menu');
			//this.target = new ModState(string.split(":")[1]);
		}
	}
}