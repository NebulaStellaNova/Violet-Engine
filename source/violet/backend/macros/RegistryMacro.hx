package violet.backend.macros;

#if macro
using violet.backend.macros.MacroUtil;

class RegistryMacro {

	public static macro function build():Array<Field> {
		final cls:ClassType = Context.getLocalClass().get();
		final fields:Array<Field> = Context.getBuildFields();

		final regMeta = cls.meta.extract(':registryData')[0];
		final idValue:Expr = {expr: EConst(CString(regMeta.params[0].stringFromMetaExpr())), pos: Context.currentPos()}
		var classType:ComplexType;
		var dataType:ComplexType;
		cls.doc = 'Handles all ${regMeta.params[0].stringFromMetaExpr()}s!' + (cls.doc == null || cls.doc.length == 0 ? '' : '\n${cls.doc}');

		switch (regMeta.params[1].expr) {
			case EArrayDecl(items):
				if (items.length < 2) throw 'Expected two registry types in @:registryData';
				classType = items[0].typeFromMetaExpr();
				dataType = items[1].typeFromMetaExpr();
			case _:
				throw 'Expected type array as second @:registryData parameter';
		}

		final classTPath:TypePath = switch (classType) {
			case TPath(p): p;
			default: null;
		}
		final tempClass = macro class TempClass {
			/**
			 * Just used internally when the function is generated via the macro.
			 */
			@:noCompletion inline static final _id:String = $idValue;

			public static final id:String = _id;
			public static final data:Array<$classType> = [];
			public static final entries:Map<String, $dataType> = new Map<String, $dataType>();

			inline public static function clearEntries():Void {
				data.resize(0);
				entries.clear();
			}

			public static function registerEntries():Void
				throw 'debug:<darkred>The <cyan>$id<darkred> registry is not setup.';
			public static function registerEntry(id:String, _data:$dataType):Void {
				if (entryExists(id)) {
					trace('warning:<orange>$_id with ID "<magenta>$id<orange>" is already registered, ignoring entry.');
					return;
				}
				entries.set(id, _data);
				data.push(new $classTPath(id));
				trace('debug:<cyan>Registered $_id entry, "<magenta>$id<cyan>".');
			}


			inline public static function entryExists(id:String):Bool return entries.exists(id);
			inline public static function fetchEntry(id:String):Null<$classType> {
				if (!entryExists(id)) // we love inlining :3
					trace('debug:<red>$_id entry "<yellow>$id<red>" doesn\'t exist.');
				return data.find(entry -> return entry.id == id);
			}

			inline public static function getAllEntryIDs():Array<String> return [for (id in entries.keys()) id];
			inline public static function getAllEntries():Array<$classType> return data.copy();
		}

		final throwableFields = ['registerEntries'];
		final autoGenFields = [
			'clearEntries',
			'registerEntry',
			'entryExists', 'fetchEntry',
			'getAllEntryIDs', 'getAllEntries'
		];

		// If you already have the function in the class, it will ignore the macro created one.
		final skippableFields = throwableFields.concat(autoGenFields);
		return fields.concat(tempClass.fields.filter((field) -> {
			if (!skippableFields.exists(f -> return f == field.name)) return true;
			final contains = fields.exists(f -> return f.name == field.name);
			if (!contains && throwableFields.contains(field.name))
				Context.info('Field "${field.name}" doesn\'t exist, expect throws to occur.', Context.currentPos());
			return !contains;
		}));
	}

}
#end