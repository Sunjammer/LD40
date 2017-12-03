package coldBoot.entities;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;
import glm.Vec2;

class Missile extends Entity
{
	var speed: Float = 53;
	var damage: Float = 3;
	
	var lifetime: Float = 3;
	var direction: Vec2;
	
	public function new(direction: Vec2)
	{
		super();
		this.direction = direction;
	}
	
	override public function onAdded()
	{
		super.onAdded();
		
	}
	
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
		lifetime -= info.deltaTime;
		if (lifetime <= 0)
		{
			info.game.getCurrentState().getRootEntity().remove(this);
		}
		
		position += direction * info.deltaTime * speed;
		
		var enemies = info.game.getCurrentState().getRootEntity().getChildEntitiesByTag("enemy");
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRoundRect(position.x, position.y, 15, 15, 8, 8);
	}

}