package coldBoot.entities;
import coldBoot.Entity;

class Sonar extends Entity
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