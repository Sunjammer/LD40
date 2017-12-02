package coldBoot.entities;

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 1;
	var timeSinceLaunch: Float;
	
	public function new() 
	{
		super();
	}
	
	override public function onAdded() 
	{
		super.onAdded();
	}
	
	override public function update(state:GamePlayState, dt:Float) 
	{
		super.update(state, dt);
		timeSinceLaunch += dt;
	}
	
	public function getCurrentRadius(): Float {
		return timeSinceLaunch * speed;
	}
}