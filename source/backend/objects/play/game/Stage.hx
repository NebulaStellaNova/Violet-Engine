package backend.objects.play.game;

import backend.scripts.Script;
import backend.scripts.PythonScript;
import backend.scripts.LuaScript;
import backend.scripts.FunkinScript;
import states.PlayState;
import flixel.FlxG;
import openfl.text.StageText;
import backend.filesystem.Paths;
import haxe.display.Display.Package;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
using StringTools;
using utils.ArrayUtil;

typedef PropAnimation = {
    var name:String;
    var prefix:String;
    var looped:Bool;
    var flipX:Bool;
    var flipY:Bool;
    var frameIndices:Array<Int>;
	var offsets:Array<Float>;
	var frameRate:Int;
}

typedef PropData = {
    var flipX:Bool;
    var flipY:Bool;
    var zIndex:Int;
    var name:String;
    var danceEvery:Int;
    var animType:String;
    var assetPath:String;
    var scale:Array<Float>;
    var scroll:Array<Float>;
    var position:Array<Float>;
    var startingAnimation:String;
    var animations:Array<PropAnimation>;
}

typedef StageCharacter = {
    var zIndex:Int;
    var position:Array<Float>;
    var cameraOffsets:Array<Float>;
}

typedef StageCharacterGroup = {
    var bf:StageCharacter;
    var dad:StageCharacter;
    var gf:StageCharacter;
}

typedef StageData = {
    var name:String;
    var directory:String;
    var cameraZoom:Float;
    var props:Array<PropData>;
    var characters:StageCharacterGroup;
}

class Stage extends FlxTypedSpriteGroup<StageProp> {

    public var stageData:StageData;
    public var scriptsToAdd:Array<Script> = [];

    public function new(id:String) {
        super();

        if (!Paths.fileExists(Paths.json('data/stages/$id'))) {
            log('Stage Not Found With ID "$id"', ErrorMessage);
            this.stageData = Paths.parseJson('data/stages/mainStage');
            return;
        }
        this.stageData = Paths.parseJson('data/stages/$id');

		var foldersToCheck = [
			'data/scripts/stages',
			'data/stages'
		];
		for (folder in foldersToCheck) {
			if (Paths.folderExists('assets/$folder')) {
				for (script in Paths.readFolder('assets/$folder')) {
                    if (script.split(".")[0] == id) {
                        if (script.endsWith(".hx") || script.endsWith(".lua") || script.endsWith(".py")) {
                            if (!Paths.readStringFromPath('assets/$folder/$script').contains("scriptDisabled = true")) {
                                scriptsToAdd.push(switch (script.split(".").getLastOf()) {
                                    case "hx":
                                        new FunkinScript('assets/$folder/$script');
                                    case "lua":
                                        new LuaScript('assets/$folder/$script');
                                    case "py":
                                        new PythonScript('assets/$folder/$script');
                                    case _:
                                        new FunkinScript('assets/$folder/$script');
                                                    
                                });
                            } else {
                                trace('Script Disabled "$script"');
                            }
                        }
                    }
				}
			}
		}
		/* for (modID in Paths.getModList()) {
			if (Paths.checkModEnabled(modID)) {
				for (folder in foldersToCheck) {
					if (Paths.folderExists('mods/$modID/$folder')) {
						for (script in Paths.readFolder('mods/$modID/$folder')) {
                            if (script.split(".")[0] == id) {
                                if (script.endsWith(".hx") || script.endsWith(".lua") || script.endsWith(".py")) {
                                    if (!Paths.readStringFromPath('mods/$modID/$folder/$script').contains("scriptDisabled = true")) {
                                        PlayState.instance.scriptsToAdd.push('mods/$modID/$folder/$script');
                                    } else {
                                        trace('Script Disabled "$script"');
                                    }
                                }
                            }
						}
					}
				}
			}
		} */

        for (prop in this.stageData.props) {
            var prop = new StageProp(prop, this);
            FlxG.state.add(prop);
            add(prop);
        }
    }

    public function getProp(id:String):StageProp {
        for (i in this.members) {
            if (i.id == id) {
                return i;
            }
        }
        log('Could not find prop with id "$id"', ErrorMessage);
        return null;
        //return new StageProp();
    }

    public function getSprite(id:String):StageProp {
        return getProp(id);
    }

    public function getNamedProp(id:String):StageProp {
        return getProp(id);
    }

}