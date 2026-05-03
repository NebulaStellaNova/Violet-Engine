package violet.backend.objects;

import violet.states.*;
import violet.states.menus.*;

class ClassData {

	public var type:String;
	public var name:String;
	public var target:Dynamic;
	public var isSubState:Bool = false;

	public function new(string:String, ?subStateTarget:Bool = false) {
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
				case "FreeplayMenu":
					this.target = new FreeplayMenu();
					this.isSubState = true;
				case "OptionsMenu":
					this.target = new OptionsMenu();
					this.isSubState = true;
				case "MoTW" | "ModOfTheWeekMenu":
					this.target = new ModOfTheWeekMenu();
					this.isSubState = true;
				/* case "CreditsState":
					this.target = new CreditsState();
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
			this.target = subStateTarget ? new ModSubState(string.split(":")[1]) : new ModState(string.split(":")[1]);
		}
	}

}