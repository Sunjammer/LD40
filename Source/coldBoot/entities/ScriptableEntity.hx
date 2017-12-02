package coldBoot.entities;
import coldBoot.Entity;
import coldBoot.UpdateInfo;
import coldBoot.Script;

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
	
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
		for (s in scripts)
			s.execute(info.deltaTime);
	}
}