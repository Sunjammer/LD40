package coldBoot.entities;
import coldBoot.IGameState;
import coldBoot.UpdateInfo;
import glm.Vec2;

class Turret extends ScriptableEntity
{
	var orientation: Float = 0;
	var shootRadius: Float = 10;
	var missileType: Missile;

	public function new()
	{
		super();
	}
	
	public function shoot(gameState: IGameState) 
	{
		var dir = new Vec2(Math.random() * 2 - 1, Math.random() * 2 - 1);
		Vec2.normalize(dir, dir);
		var ms = new Missile(dir);
		ms.position = position;
		gameState.addChildEntity(ms);
	}

	var timer: Float = 0;
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
		var state = info.game.getCurrentState();
		
		timer += info.deltaTime;
		if (timer > 1)
		{
			shoot(state);
			timer = 0;
		}
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRoundRect(position.x, position.y, 15, 15, 8, 8);
	}
}