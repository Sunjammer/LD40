package coldBoot.entities;

import coldBoot.Level;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;
import coldBoot.ai.*;
import coldBoot.states.*;
import coldBoot.entities.PulseMap.PulseTileBuffer;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import glm.Vec2;

class Enemy extends Entity implements EnemyAI.EnemyController {
	var brain:EnemyAI;
	
	var hp: Float = 20;
	var level: Level;

	public function new(level: Level, position:Vec2)
	{
		super();
		this.level = level;
		this.position = position;
		brain = new EnemyAI(false, new EnemyAI.SquadController(), level.map, this);
	}

	public function move(dir:Vec2) {
		position += dir * 4;
	}

	public override function render(info:RenderInfo) {
		brain.performAction();

		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRect(position.x-5, position.y-5, 10, 10);
	}
	
	var pulseTimer = (Math.random() + 1) * 2;
	var timer = 0.0;
	override public function update(info:UpdateInfo) 
	{
		super.update(info);
		if (hp <= 0)
			info.game.getCurrentState().getRootEntity().remove(this);
			
		timer += info.deltaTime;
		if (timer > pulseTimer)
		{
			var pulseBuffer: PulseMap = cast info.game.getCurrentState().getRootEntity().getChildEntitiesByTag("pulseMap")[0];
			
			
			var tileX = Math.floor((position.x - 5) / level.pixelSize);
			var tileY = Math.floor((position.y - 5) / level.pixelSize);
			trace("X: " + tileX + ", " + tileY);
			pulseBuffer.startPulse(tileX, tileY, 50, 1);
			timer = 0;
		}
	}
	
	public function getShape() : Shape
	{
		return Polygon.rectangle(position.x, position.y, 10, 10);
	}
	
	public function doDamage(damage: Float) 
	{
		hp -= damage;
	}
}