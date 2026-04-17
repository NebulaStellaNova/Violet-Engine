package violet.backend.scripting.psych;

import violet.backend.utils.NovaUtils;
import violet.states.PlayState;
#if CAN_LUA_SCRIPT
import flixel.util.FlxStringUtil;
import violet.backend.objects.NovaSprite;

class LuaCallbacks {

	public static var spriteCount:Int = 0;

	public static function applyPsychCallbacksToScript(script:LuaScript) {
		script.set('loadGraphic', function(variable:String, image:String) {
			if (getVar(script, variable) != null) {
				cast (getVar(script, variable), NovaSprite).loadGraphic(Paths.image(image));
			} else {
				trace('error:Unknown Lua Variable "$variable"');
				// cast (FlxG.state, violet.backend.StateBackend).debugPrint('Unknown Variable "$variable"', 'RED');
			}
		});
		script.set('addLuaSprite', function(tag:String, ?inFront:Bool = false){
			if (getVar(script, tag) != null) {
				var sprite:NovaSprite = cast getVar(script, tag);
				sprite.z = spriteCount + 1;
				trace('addLuaSprite($tag, $inFront)');
				if (inFront) sprite.z += 500;
				FlxG.state.insert(sprite.z, sprite);
				spriteCount++;
			} else {
				trace('error:Unknown Lua Variable "$tag"');
			}
		});

		script.set('removeLuaSprite', function(tag:String, ?inFront){
			if (getVar(script, tag) != null) {
				FlxG.state.remove(getVar(script, tag));
				spriteCount--;
			} else {
				trace('error:Unknown Lua Variable "$tag"');
			}
		});

		script.set('makeLuaSprite', function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0):NovaSprite {
			var sprite:NovaSprite = new NovaSprite(x, y, Paths.image(image));
			setVar(script, tag, sprite);
			return sprite;
		});

		script.set('setScrollFactor', function(obj:String, scrollX:Float, scrollY:Float) {
			if (getVar(script, obj) != null) {
				cast (getVar(script, obj), NovaSprite).scrollFactor.set(scrollX, scrollY);
			} else {
				trace('error:Unknown Lua Variable "$obj"');
			}
		});

		script.set('scaleObject', function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			if (getVar(script, obj) != null) {
				cast (getVar(script, obj), NovaSprite).scale.set(x, y);
			} else {
				trace('error:Unknown Lua Variable "$obj"');
			}
		});

		script.set('setGraphicSize', function(obj:String, x:Float, y:Float = 0, updateHitbox:Bool = true) {
			if (getVar(script, obj) != null) {
				cast (getVar(script, obj), NovaSprite).setGraphicSize(x, y);
				if (updateHitbox)
					cast (getVar(script, obj), NovaSprite).updateHitbox();
			} else {
				trace('error:Unknown Lua Variable "$obj"');
			}
		});

		script.set('updateHitbox', function(obj:String) {
			if (getVar(script, obj) != null) {
				cast (getVar(script, obj), NovaSprite).updateHitbox();
			} else
				trace('error:Unknown Lua Variable "$obj"');
		});

		script.set('screenCenter', function(obj:String, pos:String = 'xy') {
			if (getVar(script, obj) != null) {
				var sprite:NovaSprite = cast (getVar(script, obj), NovaSprite);
				sprite.screenCenter(switch (pos.toLowerCase()) {
					case 'x':
						X;
					case 'y':
						Y;
					default:
						XY;
				});
			} else {
				trace('error:Unknown Lua Variable "$obj"');
			}
		});

		script.set('getProperty', function(property:String):Dynamic {
			var daObj:Dynamic = getVar(script, property.split('.')[0]);
			for (i=>prop in property.split('.')) {
				if (i == 0) {
					daObj = getVar(script, prop);
				} else if (i != property.split('.').length-1) {
					daObj = Reflect.field(daObj, prop);
				} else {
					return Reflect.field(daObj, prop);
				}
			}
			return '';
		});

		script.set('setProperty', function(property:String, value:Dynamic) {
			var daObj:Dynamic = getVar(script, property.split('.')[0]);
			for (i=>prop in property.split('.')) {
				trace(Reflect.field(daObj, prop) + ', ' + i);
				if (i == 0) {
					daObj = getVar(script, prop);
				} else if (i != property.split('.').length-1) {
					daObj = Reflect.field(daObj, prop);
				} else {
					Reflect.setField(daObj, prop, value);
				}
			}
		});

		script.set('setObjectCamera', function(obj:String, camera:String = 'game') {
			if (getVar(script, obj) != null) {
				switch (camera) {
					case 'game' | 'camGame':
						cast (getVar(script, obj), NovaSprite).cameras = [FlxG.camera];
					case 'hud' | 'camHUD':
						cast (getVar(script, obj), NovaSprite).cameras = [PlayState.instance.camHUD];
					default:
						trace('error:Unknown Camerae "$camera"');
						// cast (FlxG.state, violet.backend.StateBackend).debugPrint('Unknown Camera "$camera"', 'RED');
				}
			}
		});

		script.set('playMusic', function(sound:String, ?volume:Float = 1, ?loop:Bool = false) {
			NovaUtils.playMusic(sound, volume).looped = loop;
		});

		script.set('debugPrint', function(text:Dynamic = '', color:String = 'WHITE') {
			// cast (FlxG.state, violet.backend.StateBackend).debugPrint(text, color);
		});
	}

	inline static function getVar(script:LuaScript, field:String) {
		return script.storedVars.get(field);
	}

	inline static function setVar(script:LuaScript, field:String, value:Dynamic) {
		script.storedVars.set(field, value);
	}

}
#end