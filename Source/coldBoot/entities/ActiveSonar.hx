package coldBoot.entities;
import coldBoot.Level;
import coldBoot.entities.Sonar;
import coldBoot.states.GamePlayState;

class ActiveSonar extends Sonar
{
	public function new()
	{
		super();
		addScriptFunction("firePulse", firePulse);
		
	}
	
	public function firePulse(level: Level)
	{
	}
	
	override public function render(state:GamePlayState) 
	{
		super.render(state);
		Main.debugDraw.graphics.beginFill(0xff0000);
		Main.debugDraw.graphics.drawCircle(position.x, position.y, 10);
	}
}