package coldBoot.entities;

import coldBoot.RenderInfo;
import coldBoot.ai.*;
import coldBoot.states.*;
import glm.Vec2;

class Enemy extends Entity implements EnemyAI.EnemyController {
	var brain:EnemyAI;

	public function new(map:PathFinding.GameMap, position:Vec2)
	{
		super();
		this.position = position;
		brain = new EnemyAI(map, this);
	}

	public function move(dir:Vec2) {
		position += dir * 4;
	}

	public override function render(info:RenderInfo) {
		brain.performAction();

		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRect(position.x-5, position.y-5, 10, 10);
	}
}