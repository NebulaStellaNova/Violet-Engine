package backend;

import states.*;

class ClassData {
	public var type:String;
	public var target:Dynamic;

	public function new(string:String) {
		this.type = string.split(":")[0];

		if (this.type == "source") {
			switch (string.split(":")[1]) {
				case "MainMenuState":
					this.target = new MainMenuState();
				case "CreditsState":
					this.target = new CreditsState();
				case "FreeplayState":
					this.target = new FreeplayState();
				case "PlayState":
					this.target = new PlayState();
				case "ModMenuState":
					this.target = new ModMenuState();
				default:
					log('Unknown State "${string.split(":")[1]}" returning to the Main Menu' , WarningMessage);
					this.target = new MainMenuState();
			}
		} else if (this.type == "mod") {
			this.target = new ModState(string.split(":")[1]);
		}
	}
}