package coldBoot.entities;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;
import differ.Collision;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import glm.Vec2;

class Missile extends Entity
{
	var speed: Float = 100;
	var damage: Float = 20;
	
	var lifetime: Float = 5;
	var direction: Vec2;
	
	var shape: Shape;
	
	public function new(direction: Vec2)
	{
		super();
		this.direction = direction;
	}
	
	override public function onAdded()
	{
		super.onAdded();
		
	}
	
	function destroyMissile(info:UpdateInfo) 
	{
		info.game.getCurrentState().getRootEntity().remove(this);
	}

	override public function update(info:UpdateInfo) 
	{
		super.update(info);
		lifetime -= info.deltaTime;
		if (lifetime <= 0)
		{
			destroyMissile(info);
		}
		
		position += direction * info.deltaTime * speed;
		
		var enemies = info.game.getCurrentState().getRootEntity().getChildEntitiesByTag("enemy");
		
		var missileShape = Polygon.rectangle(position.x, position.y, 15, 15, false);
		for (e in enemies)
		{
			var e: Enemy = cast e;
			var enemyShape = e.getShape();
			var collisionInfo = Collision.shapeWithShape(missileShape, enemyShape);
			if (collisionInfo != null)
			{
				trace("Doing damage to an enemy");
				e.doDamage(damage);
				destroyMissile(info);
				break;
			}
		}
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRoundRect(position.x, position.y, 15, 15, 8, 8);
	}

}