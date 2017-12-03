package coldBoot.entities;
import coldBoot.Entity;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;

class Base extends Entity
{
	public var hp: Float;
	
	public function new(hp: Float)
	{
		super();
		this.hp = hp;
	}
	
	function takeDamage(dmg: Float)
	{
		this.hp -= dmg;
	}
	
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0x00ff00);
		Main.debugDraw.graphics.drawRoundRect(position.x, position.y, 20, 20, 4, 4);
	}
	
}