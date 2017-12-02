package coldBoot.entities;
import coldBoot.entities.Sonar;

class ActiveSonar extends Sonar
{
	public function new()
	{
		super();
		trace("fooooooooo123");
		addScript("firePulse(dt)");
		addScriptFunction("firePulse", firePulse);
		
	}
	
	public function firePulse(dt)
	{
		trace("Active sonar fired pulse: " + dt);
	}
}