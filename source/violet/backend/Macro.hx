package violet.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {
	public static function init():Void {
		/* Compiler.addMetadata('@:build(violet.backend.Macro.buildFlxBasic())', 'flixel.FlxBasic');
		Compiler.addMetadata('@:build(violet.backend.Macro.buildFlxObject())', 'flixel.FlxObject');
		Compiler.addMetadata('@:build(violet.backend.Macro.buildFlxSprite())', 'flixel.FlxSprite');
		Compiler.addMetadata('@:build(violet.backend.Macro.buildFlxSpriteGroup())', 'flixel.FlxTypedSpriteGroup');
		#if SCRIPT_SUPPORT
		Compiler.include('violet', true);
		Compiler.include('haxe', true, ['haxe.atomic.*', 'haxe.macro.*']);
		Compiler.include('flixel', true, ['flixel.addons.editors.spine.*', 'flixel.addons.nape.*', 'flixel.system.macros.*', 'flixel.addons.tile.FlxRayCastTilemap', 'flixel.addons.weapon.*']);
		#end */
	}

	public static macro function buildFlxBasic():Array<Field> {
		var classFields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Extra data the object can hold.
			 */
			public final extra:Map<String, Dynamic> = new Map<String, Dynamic>();
			/**
			 * The layering index of the object.
			 */
			public var zIndex:Int = 0;
			/**
			 * When true the object has been destroyed, this cannot be reversed.
			 */
			public var destroyed(default, null):Bool = false;
		}

		var destroyFunc = classFields.filter(field -> return field.name == 'destroy')[0];
		switch (destroyFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					$initExpr;
					destroyed = true;
				}
				destroyFunc.kind = FFun(f);
			default:
		}
		var toStringFunc = classFields.filter(field -> return field.name == 'toString')[0];
		switch (toStringFunc.kind) {
			case FFun(f):
				f.expr = macro {
					return FlxStringUtil.getDebugString([
						LabelValuePair.weak('active', active),
						LabelValuePair.weak('visible', visible),
						LabelValuePair.weak('alive', alive),
						LabelValuePair.weak('exists', exists),
						LabelValuePair.weak('destroyed', destroyed)
					]);
				}
				toStringFunc.kind = FFun(f);
			default:
		}

		return classFields.concat(tempClass.fields);
	}
	/**
	 * Implements forceIsOnScreen from Codename Engine and makes screenCenter compatible with other cameras.
	 * @return Array<Field>
	 */
	public static macro function buildFlxObject():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * If true, the object will always be considered to be on screen.
			 */
			public var forceIsOnScreen:Bool = false;

			/**
			 * Centers this `FlxObject` on the screen, either by the x axis, y axis, or both.
			 *
			 * @param   axes   On what axes to center the object (e.g. `X`, `Y`, `XY`) - default is both.
			 * @param  camera  The camera to use for centering. If `null`, the default camera is used.
			 * @return  This FlxObject for chaining
			 */
			public function screenCenter(axes:FlxAxes = XY, ?camera:FlxCamera):FlxObject {
				camera ??= getDefaultCamera();
				if (axes.x) x = (camera.width - width) / 2 - (camera.scroll.x * -scrollFactor.x);
				if (axes.y) y = (camera.height - height) / 2 - (camera.scroll.y * -scrollFactor.y);
				return this;
			}
		}

		var onScreenFunc = classFields.filter(field -> return field.name == 'isOnScreen')[0];
		switch (onScreenFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					if (forceIsOnScreen)
						return true;
					$initExpr;
				}
				onScreenFunc.kind = FFun(f);
			default:
		}

		var newScreenCenterFunc = tempClass.fields.filter(field -> return field.name == 'screenCenter')[0];
		tempClass.fields.remove(newScreenCenterFunc);
		var screenCenterFunc = classFields.filter(field -> return field.name == 'screenCenter')[0];
		screenCenterFunc.name = newScreenCenterFunc.name;
		screenCenterFunc.doc = newScreenCenterFunc.doc;
		screenCenterFunc.access = newScreenCenterFunc.access;
		screenCenterFunc.kind = newScreenCenterFunc.kind;
		screenCenterFunc.meta = newScreenCenterFunc.meta;

		return classFields.concat(tempClass.fields);
	}
	/**
	 * Implements forceIsOnScreen from Codename Engine.
	 * @return Array<Field>
	 */
	public static macro function buildFlxSprite():Array<Field> {
		var classFields = Context.getBuildFields();

		// I hate that I hate to do this twice.
		var onScreenFunc = classFields.filter(field -> return field.name == 'isOnScreen')[0];
		switch (onScreenFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					if (forceIsOnScreen)
						return true;
					$initExpr;
				}
				onScreenFunc.kind = FFun(f);
			default:
		}

		return classFields;
	}

	/**
	 * Implements keyValueIterator because it doesn't have one for some reason???
	 * @return Array<Field>
	 */
	public static macro function buildFlxSpriteGroup():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Iterates through every member and index.
			 */
			public inline function keyValueIterator() {
				return members.keyValueIterator();
			}
		}
		return classFields.concat(tempClass.fields);
	}
}
#end