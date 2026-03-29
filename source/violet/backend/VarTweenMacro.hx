package violet.backend;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class VarTweenMacro {

    public static var macroContext:Array<Field>;

    public static var tracePos = macro {
        methodName: 'tween',
        className: 'FlxTween',
        fileName: 'FlxTween.hx',
        lineNumber: 985
    }

    public static macro function init():Array<Field> {
		macroContext = Context.getBuildFields();
        setExpr('update', macro {
            var delay:Float = (executions > 0) ? loopDelay : startDelay;

            // Leave properties alone until delay is over
            if (_secondsSinceStart < delay)
                super.update(elapsed);
            else
            {
                // Wait until the delay is done to set the starting values of tweens
                if (Math.isNaN(_propertyInfos[0].startValue))
                    setStartValues();

                super.update(elapsed);

                if (active)
                    for (info in _propertyInfos)
                        if (Reflect.getProperty(info.object, info.field) != null) Reflect.setProperty(info.object, info.field, info.startValue + info.range * scale);
                        else this.cancel();
            }
        });
        setExpr('setStartValues', macro {
            for (info in _propertyInfos)
            {
                if (Reflect.getProperty(info.object, info.field) == null)
                    violet.backend.console.Logs.traceCallback('error:The object does not have the property "${info.field}", cancelling tween.', $tracePos);

                    var value:Dynamic = Reflect.getProperty(info.object, info.field);
                    if (Math.isNaN(value)) {
                        this.cancel();
                        violet.backend.console.Logs.traceCallback('error:The property "${info.field}" is not numeric.', $tracePos);
                        break;
                    }

                    info.startValue = value;
                    info.range = info.range - value;
            }
        });
        setExpr('initializeVars', macro {
            var fieldPaths:Array<String> = [];
            if (Reflect.isObject(_properties))
                fieldPaths = Reflect.fields(_properties);
            else
                violet.backend.console.Logs.traceCallback("error:Unsupported properties container - use an object containing key/value pairs.", $tracePos);

            for (fieldPath in fieldPaths)
            {
                var target = _object;
                var path = fieldPath.split(".");
                var field = path.pop();
                for (component in path)
                {
                    target = Reflect.getProperty(target, component);
                    if (!Reflect.isObject(target))
                        violet.backend.console.Logs.traceCallback('error:The object does not have the property "$component" in "$fieldPath"', $tracePos);
                }

                _propertyInfos.push({
                    object: target,
                    field: field,
                    startValue: Math.NaN, // gets set after delay
                    range: Reflect.getProperty(_properties, fieldPath)
                });
            }
        });
		return macroContext;
	}

    public static function setExpr(fieldName:String, expr:Expr) {
        var func = macroContext.filter(field -> return field.name == fieldName)[0];
		switch (func.kind) {
			case FFun(f):
                f.expr = expr;
				func.kind = FFun(f);
			default:
        }
    }

}
#end