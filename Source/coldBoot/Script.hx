package coldboot;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

class Script 
{
	var interp: Interp;
	var expr: Expr;
	
	public function new(code: String) 
	{
		interp = new Interp();
		expr = new Parser().parseString(code);
	}
	
	public function addFunction(name: String, fun: Dynamic) 
	{
		trace("Adding func: " + name);
		interp.variables[name] = fun;
	}
	
	public function execute(dt: Float) {
		interp.variables["dt"] = dt;
		interp.execute(expr);
	}
}