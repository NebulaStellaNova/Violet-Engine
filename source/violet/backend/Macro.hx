package violet.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {
	public static function init():Void {
		Compiler.addMetadata('@:build(violet.backend.Macro.buildFlxBasic())', 'flixel.FlxBasic');
		#if SCRIPT_SUPPORT
		Compiler.include('violet', true);
		Compiler.include('haxe', true, ['haxe.atomic.*', 'haxe.macro.*']);
		Compiler.include('flixel', true, ['flixel.addons.editors.spine.*', 'flixel.addons.nape.*', 'flixel.system.macros.*', 'flixel.addons.tile.FlxRayCastTilemap', 'flixel.addons.weapon.*']);
		#end
	}

	public static macro function buildFlxBasic():Array<Field> {
		var classFields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * The layering index of the object.
			 */
			public var zIndex:Int = 0;
			/**
			 * Extra data the object can hold.
			 */
			public final extra:Map<String, Dynamic> = new Map<String, Dynamic>();
		}
		return classFields.concat(tempClass.fields);
	}
}
#end