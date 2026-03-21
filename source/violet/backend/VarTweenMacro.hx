package violet.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;


class VarTweenMacro {
    public static macro function init():Array<Field> {
		var classFields = Context.getBuildFields();
        classFields = setExpr(classFields, 'update', macro {
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
        classFields = setExpr(classFields, 'setStartValues', macro {
            for (info in _propertyInfos)
            {
                if (Reflect.getProperty(info.object, info.field) == null)
                    violet.backend.console.Logs.traceCallback('error:The object does not have the property "${info.field}", cancelling tween.', {
                        methodName: 'tween',
                        className: 'FlxTween',
                        fileName: 'FlxTween.hx',
                        lineNumber: 985
                    });

                    var value:Dynamic = Reflect.getProperty(info.object, info.field);
                    if (Math.isNaN(value)) {
                        this.cancel();
                        violet.backend.console.Logs.traceCallback('error:The property "${info.field}" is not numeric.', {
                            methodName: 'tween',
                            className: 'FlxTween',
                            fileName: 'FlxTween.hx',
                            lineNumber: 985
                        });
                        break;
                    }

                    info.startValue = value;
                    info.range = info.range - value;
            }
        });
        classFields = setExpr(classFields, 'initializeVars', macro {
            var fieldPaths:Array<String> = [];
            if (Reflect.isObject(_properties))
                fieldPaths = Reflect.fields(_properties);
            else
                violet.backend.console.Logs.traceCallback("error:Unsupported properties container - use an object containing key/value pairs.", {
                    methodName: 'tween',
                    className: 'FlxTween',
                    fileName: 'FlxTween.hx',
                    lineNumber: 985
                });

            for (fieldPath in fieldPaths)
            {
                var target = _object;
                var path = fieldPath.split(".");
                var field = path.pop();
                for (component in path)
                {
                    target = Reflect.getProperty(target, component);
                    if (!Reflect.isObject(target))
                        violet.backend.console.Logs.traceCallback('error:The object does not have the property "$component" in "$fieldPath"', {
                            methodName: 'tween',
                            className: 'FlxTween',
                            fileName: 'FlxTween.hx',
                            lineNumber: 985
                        });
                }

                _propertyInfos.push({
                    object: target,
                    field: field,
                    startValue: Math.NaN, // gets set after delay
                    range: Reflect.getProperty(_properties, fieldPath)
                });
            }
        });
		return classFields;
	}

    public static function setExpr(fields:Array<Field>, fieldName:String, expr:Expr):Array<Field> {
        var func = fields.filter(field -> return field.name == fieldName)[0];
		switch (func.kind) {
			case FFun(f):
                f.expr = expr;
				func.kind = FFun(f);
			default:
        }
        return fields;
    }
}

#end