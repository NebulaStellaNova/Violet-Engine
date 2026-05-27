package violet.backend.macros;

#if macro
class MacroUtil {

	public static function typePathFromExpr(expr:Expr):String {
		switch (expr.expr) {
			case EField(e, field, _):
				return '${typePathFromExpr(e)}.$field';
			case EConst(CIdent(name)):
				return name;
			case EParenthesis(e):
				return typePathFromExpr(e);
			default:
				throw 'Unsupported registry metadata type expression: ${expr.expr}';
		}
	}

	public static function stringFromMetaExpr(expr:Expr):String {
		switch (expr.expr) {
			case EMeta(_, e):
				return stringFromMetaExpr(e);
			case ECheckType(e, _):
				return stringFromMetaExpr(e);
			case EParenthesis(e):
				return stringFromMetaExpr(e);
			case EConst(CString(value)):
				return value;
			case EConst(CIdent(value)):
				return value;
			default:
				return Std.string(expr.getValue());
		}
	}

	public static function intFromMetaExpr(expr:Expr):Int {
		switch (expr.expr) {
			case EMeta(_, e):
				return intFromMetaExpr(e);
			case ECheckType(e, _):
				return intFromMetaExpr(e);
			case EParenthesis(e):
				return intFromMetaExpr(e);
			case EConst(CInt(value)):
				var parsed:Null<Int> = Std.parseInt(value);
				return parsed == null ? 0 : parsed;
			case EConst(CString(value)):
				var parsed2:Null<Int> = Std.parseInt(value);
				return parsed2 == null ? 0 : parsed2;
			case EConst(CIdent(value)):
				var parsed3:Null<Int> = Std.parseInt(value);
				return parsed3 == null ? 0 : parsed3;
			default:
				var parsed4:Null<Int> = Std.parseInt(Std.string(expr.getValue()));
				return parsed4 == null ? 0 : parsed4;
		}
	}

	public static function exprFromClassType(classType:ClassType):Expr {
		var segments = classType.pack.copy();
		segments.push(classType.name);
		var expr:Expr = {expr: EConst(CIdent(segments[0])), pos: Context.currentPos()};
		for (i in 1...segments.length) {
			expr = {expr: EField(expr, segments[i]), pos: Context.currentPos()};
		}
		return expr;
	}

	public static function typeFromMetaExpr(expr:Expr):ComplexType {
		switch (expr.expr) {
			case EMeta(_, e):
				return typeFromMetaExpr(e);
			case ECheckType(_, t):
				return t;
			case EField(_, _, _) | EConst(CIdent(_)) | EParenthesis(_):
				var path = typePathFromExpr(expr);
				return Context.getType(path).toComplexType();
			default:
				var typed = Context.typeExpr(expr);
				return typed.t.toComplexType();
		}
	}

}
#end