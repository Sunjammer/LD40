package coldBoot.entities;
import coldBoot.Entity;
import coldBoot.UpdateInfo;
import coldBoot.states.GamePlayState;

class Sonar extends ScriptableEntity
{
	var radius: Float = 10;

	public function new()
	{
		super();
	}
	
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
	} 
}