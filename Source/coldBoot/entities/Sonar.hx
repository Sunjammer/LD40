package coldBoot.entities;
import Source.coldBoot.IReactToSonarSignals;
import coldBoot.Entity;
import coldBoot.UpdateInfo;
import coldBoot.states.GamePlayState;

class Sonar extends ScriptableEntity implements IReactToSonarSignals
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
	
	
	/* INTERFACE Source.coldBoot.IReactToSonarSignals */
	
	public function signal(pulseType:Int):Void 
	{
		//send signal to whatever script is currently active
	}
}