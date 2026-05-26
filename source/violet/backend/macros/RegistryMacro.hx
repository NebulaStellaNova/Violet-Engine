package violet.backend.macros;

#if macro
using violet.backend.macros.MacroUtil;

class RegistryMacro {

	public static macro function buildRegistry():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		var regMeta = cls.meta.extract(':registryData')[0];
		var idValue:Expr = {expr: EConst(CString(regMeta.params[0].stringFromMetaExpr())), pos: Context.currentPos()}
		var typeArgs:Expr = regMeta.params[1];
		var classType:ComplexType;
		var dataType:ComplexType;

		switch (typeArgs.expr) {
			case EArrayDecl(items):
				if (items.length < 2) throw 'Expected two registry types in @:registryData';
				classType = items[0].typeFromMetaExpr();
				dataType = items[1].typeFromMetaExpr();
			case _:
				throw 'Expected type array as second @:registryData parameter';
		}

		var tempClass = macro class TempClass {
			public static final id:String = $idValue;
			public static final data:Array<$classType> = [];
			public static final entries:Map<String, $dataType> = new Map<String, $dataType>();

			inline public static function clearEntries():Void {
				data.resize(0);
				entries.clear();
			}

			public static function registerEntries():Void {
				throw 'debug:<darkcyan>$id registry is not setup.';
			}
			inline public static function registerEntry(id:String, data:Dynamic):Void {
				throw 'debug:<darkcyan>$id registry is not setup.';
			}


			inline public static function entryExists(id:String):Bool {
				// yes, you need to set this up too
				throw 'debug:<darkcyan>$id registry is not setup.';
			}
			inline public static function fetchEntry(id:String):Null<Dynamic> {
				throw 'debug:<darkcyan>$id registry is not setup.';
			}

			inline public static function getAllEntryIDs():Array<String>
				return [for (id in entries.keys()) id];
			inline public static function getAllEntries():Array<Dynamic>
				return data.copy();
		}

		// If you already have the function in the class, it will ignore the macro created one.
		var skippableFields = ['registerEntries', 'registerEntry', 'fetchEntry', 'entryExists'];
		return fields.concat(tempClass.fields.filter((field) -> {
			if (!skippableFields.exists(f -> return f == field.name)) return true;
			final contains = fields.exists(f -> return f.name == field.name);
			if (!contains) Context.info('Field "${field.name}" doesn\'t exist, expect throws to occur.', Context.currentPos());
			return !contains;
		}));
	}

}
#end