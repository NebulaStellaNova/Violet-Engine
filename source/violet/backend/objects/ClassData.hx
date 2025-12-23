package violet.backend.objects;

import violet.states.*;
import violet.states.menus.*;

class ClassData {
	public var type:String;
	public var name:String;
	public var target:Dynamic;
	public var isSubState:Bool = false;

	public function new(string:String) {
		this.type = string.split(":")[0];
		this.name = string.split(":")[1];
		this.target = new MainMenu();
		if (this.type == "source") {
			switch (string.split(":")[1]) {
				case "TitleState":
					this.target = new TitleState();
				case "MainMenu":
					this.target = new MainMenu();
				case "StoryMenu":
					this.target = new StoryMenu();
					this.isSubState = true;
				/* case "CreditsState":
					this.target = new CreditsState();
				case "FreeplayState":
					this.target = new FreeplayState();
				case "PlayState":
					this.target = new PlayState(); */
				case "CreditsMenu":
					this.target = new CreditsMenu();
					this.isSubState = true;
				case "ModMenu":
					this.target = new ModMenu();
					this.isSubState = true;
				default:
					trace('error:Unknown State "${string.split(":")[1]}" returning to the Main Menu');
			}
		} else if (this.type == "mod") {
			trace('error:Modded States are not implemented, returning to the Main Menu');
			//this.target = new ModState(string.split(":")[1]);
		}
	}
}