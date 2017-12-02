package coldBoot.entities;

import coldBoot.ai.*;
import coldBoot.states.*;
import glm.Vec2;

class Enemy extends Entity implements EnemyAI.EnemyController {
	var brain:EnemyAI;

	public function new(map:PathFinding.GameMap)
	{
		super();
		position.x = 60;
		position.y = 60;
		brain = new EnemyAI(map, this);
	}

	public function move(dir:Vec2) {
		position += dir * 4;
	}

	public override function render(state:GamePlayState) {
		brain.performAction();

		Main.debugDraw.graphics.beginFill(0x00ffff);
		Main.debugDraw.graphics.drawRect(position.x-5, position.y-5, 10, 10);
	}
}