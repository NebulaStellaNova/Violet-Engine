package backend;

import flixel.FlxG;
import haxe.to.Path;

using StringTools;

typedef Boolean = Bool;

class GlobalResources {
	public static var jsonFilePaths:Array<String> = [];
}

class CommandPrompt {
    private var state:String;
    private var variables:Map<String, Dynamic>;
	public var active:Boolean = true; //I thought it'd be funny to add this.

    public function new() {
        this.state = "default";
        this.variables = new Map();
    }

    public function start():Void {
        print("Commands activated.");

        while (true) {
            // print("\nInput enabled.");
			if (!active) {
				print("Commands disabled.\nTO re-enable, restart the game.");
				break;
			}
            var input:String = Sys.stdin().readLine();

            if (input == "$exit") {
                print("Exiting...");
				//Main.closeGame();
				Sys.exit(0);
				print("Killing CommandHook...");
                break;
            }

			if (input == "$reset") {
				print("Resetting game...");
				//var processChecker = new Process("MixEngine.exe", ["check"]);
			}

            this.executeCommand(input);
        }
    }
	// public function remove()
	// {this = null;}

	private function executeCommand(input:String):Void {
		var parts = input.split(" ");
		var command = parts[0];
		var args = parts.slice(1);

		var combinedArgs:Array<String> = [];
		var combinedArgsMap:Array<{position:Int, value:String}> = [];
		var i = 0;

		while (i < args.length) {
			var arg = args[i];
			if (arg.startsWith("'") || arg.startsWith('"')) {
				var combinedArg:String = arg;
				var quote:String = arg.charAt(0);
				var startPos:Int = i;
				i++;
				while (i < args.length && !args[i].endsWith(quote)) {
					combinedArg += " " + args[i];
					i++;
				}
				if (i < args.length) {
					combinedArg += " " + args[i];
				} else {
					print("Error: Unterminated quotes.");
					return;
				}
				combinedArgsMap.push({position: startPos, value: combinedArg});
			} else {
				combinedArgs.push(arg);
			}
			i++;
		}

		// Reconstruct the args array using the combinedArgsMap
		var finalArgs:Array<String> = [];
		var mapIndex = 0;
		var doubleQuote = '"';
		var singleQuote = "'";

		for (i in 0...args.length) {
			if (mapIndex < combinedArgsMap.length && combinedArgsMap[mapIndex].position == i) {
				finalArgs.push(combinedArgsMap[mapIndex].value);
				mapIndex++;
				// Skip the indices that were part of the combined argument
				while (i < args.length && (!args[i].endsWith(singleQuote) && !args[i].endsWith(doubleQuote))) {
				}
			} else {
				finalArgs.push(args[i]);
			}
		}

		function containsTrue(array:Array<Bool>)
		{
			for (i in 0...array.length)
			{
				if (array[i] == true)
				{
					return true;
				}
			}
			return false;
		}

		// Now finalArgs contains the correctly combined arguments
		// You can proceed with using finalArgs as needed


		switch (Path.removeTrailingSlashes(command)) {
			case "switchState":
				if (args.length == 1) {
					this.switchState(args[0]);
				} else {
					print("Error: switchState requires exactly one argument.");
				}
			case "secretCode":
				if (args.length == 1) {
					this.secretCode(args[0]);
				} else {
					print("Error: secretCode requires exactly one argument.");
				}
			case "exit":
				Sys.exit(0);
			case "resetState":
				if (args.length == 0) {
					FlxG.resetState();
				} else {
					print("Error: resetState does not accept any arguments.");
				}
			case "debugMenu":
				if (args.length == 0) {
					this.switchState("backend.TestState");
				} else {
					print("Error: debugMenu does not accept any arguments.");
				}
			case "forceSecret":
				if (args.length == 1) {
					//states.MainMenuState.secretOverride = args[0];
					this.switchState("states.MainMenuState");
				} else {
					print("Error: forceSecret requires exactly one argument.");
				}
			case "clearSecret":
				if (args.length == 0) {
					//states.MainMenuState.secretOverride = null;
					this.switchState("states.MainMenuState");
				} else {
					print("Error: clearSecret does not accept any arguments.");
				}
			case "help":
				if (args.length == 0) {
					var list:Map<String, String> = getCommandList();
					print("List of Commands:");
					for (key => value in list) {
						print('\n/$key:\n\t$value');
					}
				} else {
					var list:Map<String, String> = getCommandList();
					//print("List of Commands:");
					for (key => value in list) {
						if (key == args[0]) {
							print('\n/$key:\n\t$value');
						}
					}
				}
		}
	}

	private function getCommandList():Map<String, String> {
		return [
			"switchState" => "INFO: Switches the state.\n\tARGS: <statePath>",
			"resetState" => "INFO: Resets the current state.",
			"exit" => "INFO: Closes the game FULLY.",
			"help" => "INFO: Shows this screen.\n\tARGS: <commandName:OptionalArg>"
		];
	}

	private function switchState(newState:String):Void {
		var stateType:Class<Dynamic> = Type.resolveClass(newState);
		if (stateType != null) {
			FlxG.switchState(Type.createInstance(stateType, []));
			print("State switched to: " + newState);
		} else {
			print("Error: Invalid state name.");
		}
	}

    private function secretCode(code:String):Void {

        print("Secret code entered: " + code);
		print("Not yet implemented.");
    }

    private function print(message:String):Void {
        Sys.stdout().writeString(message + "\n");
    }
}
