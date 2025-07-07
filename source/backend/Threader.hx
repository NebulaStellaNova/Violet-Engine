package backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;

import sys.thread.Thread;

class Threader {
    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name, Context.currentPos());
        //trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + name);
        return macro {
            #if sys
            var thrd = sys.thread.Thread.create(function() {
                try {
                    trace("Set command to run in a thread...");
                    if ($nameExpr != "") {
                        trace("Thread name: " + $nameExpr);
                    }
                    $expr;
                    if ($sleepExpr > 0) {
                        Sys.sleep($sleepExpr);
                    }
                    trace("Thread finished running command.");
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e);
                    if ($nameExpr != "") {
                        trace("Errored Thread name: " + $nameExpr);
                    }
                }
            });
            #else
            $expr;
            #end
        };
        trace("Threaded section of code prepared.");
    }

    // public static macro function addLogging(expr:Expr):Expr {
    //     return switch (expr.expr) {
    //         case EFunction(args, body):
    //             var newExprs = [];
    //             newExprs.push(macro trace("Starting function..."));
    //             for (e in body.exprs) {
    //                 newExprs.push(addLogging(e));
    //             }
    //             newExprs.push(macro trace("Function execution completed."));
    //             body.exprs = newExprs;
    //             return macro $expr;
    //         case EIf(cond, e1, e2):
    //             return macro {
    //                 trace("Evaluating condition: " + $cond.toString());
    //                 if ($cond) {
    //                     trace("Condition true");
    //                     $addLogging(e1);
    //                 } else {
    //                     trace("Condition false");
    //                     $addLogging(e2);
    //                 }
    //             };
    //         default:
    //             return expr;
    //     }
    // }
}

