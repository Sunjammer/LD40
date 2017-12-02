package coldBoot.entities;
import coldBoot.Entity;
import coldBoot.states.GamePlayState;

class Sonar extends ScriptableEntity
{
	var radius: Float = 10;

	public function new()
	{
		super();
	}
	
	override public function update(state:GamePlayState, dt:Float) 
	{
		super.update(state, dt);
	} 
}