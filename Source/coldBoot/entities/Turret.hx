package coldBoot.entities;

class Turret extends ScriptableEntity
{
	var orientation: Float = 0;
	var shootRadius: Float = 10;
	var missileType: Missile;

	public function new()
	{
		super();
	}
	
	public function shoot() 
	{
		trace("Turret fired shot");
	}

}