package violet.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {

	public static function print(message:String) {
		Sys.println("\r\x1b[92m" + '[   MACRO   ] -> [  Macro.hx  ]: ' + "\033[0m" + '$message');
	}

	public static function addMetadata(buildPath:String, classPath:String) {
		Compiler.addMetadata(buildPath, classPath);
		print('Built $classPath.');
	}

	public static function init():Void {
		print('Initializing macros...');
		addMetadata('@:build(violet.backend.Macro.buildFlxBasic())', 'flixel.FlxBasic');
		addMetadata('@:build(violet.backend.Macro.buildFlxObject())', 'flixel.FlxObject');
		addMetadata('@:build(violet.backend.Macro.buildFlxSprite())', 'flixel.FlxSprite');
		addMetadata('@:build(violet.backend.Macro.buildFlxTypedGroup())', 'flixel.group.FlxTypedGroup');
		addMetadata('@:build(violet.backend.Macro.buildFlxSpriteGroup())', 'flixel.group.FlxTypedSpriteGroup');
		addMetadata('@:build(violet.backend.Macro.buildFlxCamera())', 'flixel.FlxCamera');
		addMetadata('@:build(violet.backend.VarTweenMacro.init())', 'flixel.tweens.misc.VarTween');
		#if SCRIPT_SUPPORT
		Compiler.include('violet', true);
		Compiler.include('haxe', true, ['haxe.atomic.*', 'haxe.macro.*']);
		Compiler.include('flixel', true, ['flixel.addons.editors.spine.*', 'flixel.addons.nape.*', 'flixel.system.macros.*', 'flixel.addons.tile.FlxRayCastTilemap', 'flixel.addons.weapon.*']);
		#end
		Compiler.include('moonchart', true, ['moonchart.backend.*']); // force include, no matter what
		print('Finished building macros.');
	}

	public static macro function buildFlxCamera():Array<Field> {
		var classFields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Adds a FlxShader as a filter to the camera
			 * @param shader Shader to add
			 * @return ShaderFilter
			 */
			public function addShader(shader:FlxShader) {
				var filter:openfl.filters.ShaderFilter = null;
				if (filters == null) filters = [];
				filters.push(filter = new openfl.filters.ShaderFilter(shader));
				return filter;
			}
		}

		return classFields.concat(tempClass.fields);
	}

	public static macro function buildFlxBasic():Array<Field> {
		var classFields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Signal's to help make scripting more convenient... ig
			 */
			public var onUpdate = new flixel.util.FlxSignal.FlxTypedSignal<Float->Void>();
			// Doesn't work tho idk why ??


			/**
			 * Extra data the object can hold.
			 */
			public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
			/**
			 * The layering index of the object.
			 */
			public var zIndex:Int = 0;

			public var z(get, set):Int;
			function get_z() return zIndex;
			function set_z(v:Int) return zIndex = v;
		}

		var updateFunc = classFields.filter(field -> return field.name == 'update')[0];
		switch (updateFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					$initExpr;
					// trace(onUpdate); // <---- And this traces so idk...
					onUpdate.dispatch(elapsed); // See I'm even running it
				}
				updateFunc.kind = FFun(f);
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

	public static macro function buildFlxTypedGroup():Array<Field> {
		var classFields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * The property sort the objects by.
			 */
			public var sortBy:String = "zIndex";

			public var last(get, never):T;
			function get_last() return this.members.copy().pop();
		}

		var drawFuncy = classFields.filter(field -> return field.name == 'draw')[0];
		switch (drawFuncy.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					members.sort((a, b)->{
						if (a == null || b == null) return 0;
						if (!(Reflect.hasField(a, sortBy) || Reflect.hasField(b, sortBy))) return 0;
						final aOutput = Reflect.getProperty(a, sortBy);
						final bOutput = Reflect.getProperty(b, sortBy);
						if (Math.isNaN(aOutput) || Math.isNaN(bOutput)) return 0;
						return flixel.util.FlxSort.byValues(-1, aOutput, bOutput);
					});
					$initExpr;
				}
				drawFuncy.kind = FFun(f);
			default:
		}

		return classFields.concat(tempClass.fields);
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