package coldboot.rendering.opengl;

import lime.graphics.opengl.GL;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

class GLDebug {

  public static function build():Array<Field> {
    var fields = Context.getBuildFields();
    #if debug
    for(f in fields){
      switch(f){
        case {meta:[{name:"gldebug"}]}:
          switch(f.kind){
            case FFun(fn):
              switch(fn.expr.expr){
                case EBlock(exprs):
                  var sl = exprs.length;
                  var toAdd:Array<Dynamic> = [];
                  for(e in exprs){
                    var outExpr = Context.parse("
                        {
                            var error:Int;
                            if ((error = lime.graphics.opengl.GL.getError()) != 0) {
                              trace('GL error: ' + error);
                            }
                        }", e.pos);
                    toAdd.push(outExpr);
                  }
                  var i = 0;
                  var j = 0;
                  while(j < toAdd.length){
                    exprs.insert(i+1, toAdd[j]);
                    i++;
                    j++;
                  }
                default:
              }
            default:
          }
        default:
      }
    }
    #end
    return fields;
  }
}