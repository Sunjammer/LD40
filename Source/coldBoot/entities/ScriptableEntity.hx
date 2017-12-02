package coldBoot.entities;
import coldBoot.Entity;
import coldBoot.Script;
import coldBoot.states.GamePlayState;

class ScriptableEntity extends Entity
{
	var scripts: Array<Script> = [];

	public function new() 
	{
		super();
	}
	
	public function addScriptFunction(name: String, fun: Dynamic) 
	{
		for (s in scripts)
			s.addFunction(name, fun);
	}
	
	public function addScript(code: String)
	{
		scripts.push(new Script(code));
	}
	
	override public function update(state:GamePlayState, dt:Float) 
	{
		super.update(state, dt);
		for (s in scripts)
			s.execute(dt);
	}
}