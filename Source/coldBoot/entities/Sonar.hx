package coldboot.entities;
import Source.coldboot.IReactToSonarSignals;
import coldboot.Entity;
import coldboot.UpdateInfo;
import coldboot.states.GamePlayState;

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
	
	
	/* INTERFACE Source.coldboot.IReactToSonarSignals */
	
	public function signal(pulseType:Int):Void 
	{
		//send signal to whatever script is currently active
	}
}