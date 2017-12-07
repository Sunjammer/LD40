package coldboot.entities;
import coldboot.Level;
import coldboot.RenderInfo;
import coldboot.entities.Sonar;
import coldboot.states.GamePlayState;

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
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0xff0000);
		Main.debugDraw.graphics.drawCircle(position.x, position.y, 10);
	}
}