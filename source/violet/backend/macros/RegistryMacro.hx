package violet.backend.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class RegistryMacro {
	public static macro function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		return fields;
	}
}
#end