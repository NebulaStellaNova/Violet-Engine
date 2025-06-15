package backend.scripts.psych;

import lscript.LScript;
import flixel.text.FlxText;
import states.PlayState;
import flixel.FlxG;
import backend.filesystem.Paths;
import flixel.util.FlxStringUtil;
import backend.objects.NovaSprite;

class LuaCallbacks {

    
    public static function applyPsychCallbacksToScript(script:LuaScript) {
        script.set("loadGraphic", function(variable:String, image:String) {
            if (getVar(script, variable) != null) {
                if (FlxStringUtil.getClassName(getVar(script, variable), true) == "NovaSprite" || FlxStringUtil.getClassName(getVar(script, variable), true) == "FlxSprite") {
                    cast (getVar(script, variable), NovaSprite).loadGraphic(Paths.image(image));
                }
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Variable "$variable"', "RED");
            }
        });
        script.set("addLuaSprite", function(tag:String, ?inFront){
            trace(getVar(script, tag));
            if (getVar(script, tag) != null) {
                //if (FlxStringUtil.getClassName(getVar(script, tag), true) == "NovaSprite" || FlxStringUtil.getClassName(getVar(script, tag), true) == "FlxSprite") {
                    FlxG.state.add(getVar(script, tag));
                //}
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Sprite "$tag"', "RED");
            }
        });

        script.set("removeLuaSprite", function(tag:String, ?inFront){
            if (getVar(script, tag) != null) {
                if (FlxStringUtil.getClassName(getVar(script, tag), true) == "NovaSprite" || FlxStringUtil.getClassName(getVar(script, tag), true) == "FlxSprite") {
                    FlxG.state.remove(getVar(script, tag));
                }
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Sprite "$tag"', "RED");
            }
        });

        script.set("makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0):NovaSprite {
            var sprite:NovaSprite = new NovaSprite(x, y, Paths.image(image));
            setVar(script, tag, sprite);
            return sprite;
        });

        script.set("setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
            if (getVar(script, obj) != null) {
                cast (getVar(script, obj), NovaSprite).scrollFactor.set(scrollX, scrollY);
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Variable "$obj"', "RED");
            }
        });

        script.set("scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
            if (getVar(script, obj) != null) {
                cast (getVar(script, obj), NovaSprite).scale.set(x, y);
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Variable "$obj"', "RED");
            }
        });

        script.set("setGraphicSize", function(obj:String, x:Float, y:Float = 0, updateHitbox:Bool = true) {
            if (getVar(script, obj) != null) {
                // if (FlxStringUtil.getClassName(getVar(script, tag), true) == "NovaSprite" || FlxStringUtil.getClassName(getVar(script, tag), true) == "FlxSprite") {
                cast (getVar(script, obj), NovaSprite).setGraphicSize(x, y);
                if (updateHitbox)
                    cast (getVar(script, obj), NovaSprite).updateHitbox();
                // }
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Variable "$obj"', "RED");
            }
        });

        script.set("updateHitbox", function(obj:String) {
            if (getVar(script, obj) != null) {
                cast (getVar(script, obj), NovaSprite).updateHitbox();
            }
        });

        script.set("screenCenter", function(obj:String, pos:String = 'xy') {
            if (getVar(script, obj) != null) {
                var sprite:NovaSprite = cast (getVar(script, obj), NovaSprite);
                sprite.screenCenter(switch (pos.toLowerCase()) {
                    case "x":
                        X;
                    case "y":
                        Y;
                    default:
                        XY;
                });
            } else {
                cast (FlxG.state, MusicBeatState).debugPrint('Unknown Variable "$obj"', "RED");
            }
        });
        
        script.set("getProperty", function(property:String):Dynamic {
            var daObj:Dynamic = getVar(script, property.split(".")[0]);
            for (i=>prop in property.split(".")) {
                trace(Reflect.field(daObj, prop) + ", " + i);
                if (i == 0) {
                    daObj = getVar(script, prop);
                } else if (i != property.split(".").length-1) {
                    daObj = Reflect.field(daObj, prop);
                } else {
                    return Reflect.field(daObj, prop);
                }
            }
            cast (FlxG.state, MusicBeatState).debugPrint('Unknown Property "$property"', "RED");
            return "";
        });
        
        script.set("setProperty", function(property:String, value:Dynamic) {
            var daObj:Dynamic = getVar(script, property.split(".")[0]);
            for (i=>prop in property.split(".")) {
                trace(Reflect.field(daObj, prop) + ", " + i);
                if (i == 0) {
                    daObj = getVar(script, prop);
                } else if (i != property.split(".").length-1) {
                    daObj = Reflect.field(daObj, prop);
                } else {
                    Reflect.setField(daObj, prop, value);
                }
            }
        });

        script.set("setObjectCamera", function(obj:String, camera:String = 'game') {
            if (getVar(script, obj) != null) {
                switch (camera) {
                    case "game" | "camGame":
                        cast (getVar(script, obj), NovaSprite).cameras = [FlxG.camera];
                    case "hud" | "camHUD":
                        cast (getVar(script, obj), NovaSprite).cameras = [PlayState.camHUD];
                    default:
                         cast (FlxG.state, MusicBeatState).debugPrint('Unknown Camera "$camera"', "RED");
                }
            }
        });

        script.set("playMusic", function(sound:String, ?volume:Float = 1, ?loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});

        script.set("debugPrint", function(text:Dynamic = '', color:String = 'WHITE') {
            cast (FlxG.state, MusicBeatState).debugPrint(text, color);
        });
    }

    public static function getVar(script:LuaScript, field:String) {
        return script.psychVariables.get(field);
    }

    public static function setVar(script:LuaScript, field:String, value:Dynamic) {
        script.psychVariables.set(field, value);
    }
}