package violet.backend.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

class FlxMacro {
	public static macro function buildFlxBasic():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		var tempClass:TypeDefinition = macro class TempClass {
			/**
			 * The current layering index of this sprite
			 */
			public var zIndex:Int = 0;
			/**
			 * Extra data to store in a sprite.
			 */
			public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
		}
		trace(tempClass);
		return fields.concat(tempClass.fields);
	}
}