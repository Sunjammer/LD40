package coldBoot.entities;
import coldBoot.Level;
import coldBoot.states.GamePlayState;
import differ.Collision;
import differ.data.RayCollision;
import differ.math.Vector;
import differ.shapes.Polygon;
import differ.shapes.Ray;
import differ.shapes.Shape;
import glm.Vec2;

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 1;
	var timeSinceLaunch: Float;
	var level:Level;
	
	var rays: Array<Ray>;
	var collisions: Array<Vec2> = [];
	
	public function new(level: Level)
	{
		super();
		this.level = level;
	}
	
	override public function onAdded()
	{
		super.onAdded();
		generateRays();
		traceRays();
	}
	
	override public function update(state:GamePlayState, dt:Float) 
	{
		super.update(state, dt);
		timeSinceLaunch += dt;
	}
	
	function generateRays()
	{
		trace("Genrating rays");
		rays = [];
		var nRays = 1;
		var rayLength = 60;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentSize * i;
			var endVec = new Vector(
				(Math.cos(angle) * rayLength) + position.x, 
				(Math.sin(angle) * rayLength) + position.y);
			var startVec = new Vector(position.x, position.y);
			var r = new Ray(startVec, endVec);
			rays.push(r);
		}
	}
	
	function traceRays()
	{
		for (r in rays)
		{
			for (y in 0...level.levelData.length)
			{
				for (x in 0...level.levelData[y].length)
				{
					var wall = Polygon.rectangle(x * level.tileSize, y * level.tileSize, level.tileSize, level.tileSize, false);
					var collideInfo  = Collision.rayWithShape(r, wall);
                    if (collideInfo != null)
                    {
                        var hitX = RayCollisionHelper.hitStartX(collideInfo);
						var hitY = RayCollisionHelper.hitStartY(collideInfo);
						trace("Got collision: X: " + hitX + ", Y: " + hitY);
						collisions.push(new Vec2(hitX, hitY));
                    }
				}
			}
		}
	}
	
	override public function render(state:GamePlayState) 
	{
		super.render(state);
		Main.debugDraw.graphics.lineStyle(3, 0x0000ff);
		for (r in rays)
		{
			Main.debugDraw.graphics.moveTo(r.start.x, r.start.y);
			Main.debugDraw.graphics.lineTo(r.end.x, r.end.y);
		}
		Main.debugDraw.graphics.beginFill(0xff00ff);

		for (c in collisions)
			Main.debugDraw.graphics.drawCircle(c.x, c.y, 3);

	}
	
}