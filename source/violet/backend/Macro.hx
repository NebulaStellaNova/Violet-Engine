package violet.backend;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {
	public static macro function buildFlxBasic():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * The layering index of the object.
			 */
			public var zIndex:Int = 0;
			/**
			 * Extra data the object can hold.
			 */
			public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
		}
		return fields.concat(tempClass.fields);
	}
}

// @:build(violet.backend.Macro.buildFlxBasic())
class Test {
	public function new() {
		trace('cheese');
		trace(Type.getInstanceFields(Test));
	}
}