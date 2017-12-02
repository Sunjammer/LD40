package coldBoot.entities;
import coldBoot.Entity;

class Turret extends Entity
{
	var orientation: Float = 0;
	var shootRadius: Float = 10;
	var missileType: Missile;

	public function new()
	{
		super();
	}

}