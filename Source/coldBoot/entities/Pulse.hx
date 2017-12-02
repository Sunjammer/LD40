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

class PulseRay
{
	var ray: Ray;
	var closestHit: RayCollision;
	var pulseProgress: Float;
	public function new(r: Ray)
	{
		ray = r;
	}
	
	public function checkCollision(wall: Shape)
	{
		var collideInfo  = Collision.rayWithShape(ray, wall);
		if (collideInfo != null)
		{
			if (closestHit == null)
				closestHit = collideInfo;
			else if (collideInfo.start < closestHit.start)
			{
				closestHit = collideInfo;
			}
		}
	}
	
	public function update(pulseProgress: Float)
	{
		this.pulseProgress = pulseProgress;
	}
	
	public function render()
	{
		Main.debugDraw.graphics.lineStyle(1, 0x0000ff);
		Main.debugDraw.graphics.moveTo(ray.start.x, ray.start.y);
		Main.debugDraw.graphics.lineTo(ray.end.x, ray.end.y);
		
		
		var start = new Vec2(ray.start.x, ray.start.y);
		var end = new Vec2(ray.end.x, ray.end.y);
		var outRay = new Vec2();
		var pulseRayPos = Vec2.lerp(start, end, pulseProgress, outRay);
		Main.debugDraw.graphics.drawCircle(pulseRayPos.x, pulseRayPos.y, 2);
		
		Main.debugDraw.graphics.beginFill(0xff00ff);
		if (closestHit != null)
		{
			var x = RayCollisionHelper.hitStartX(closestHit);
			var y = RayCollisionHelper.hitStartY(closestHit);
			Main.debugDraw.graphics.drawCircle(x, y, 2);
		}
	}
}

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 0.08;
	var timeSinceLaunch: Float;
	var level:Level;

	var rays: Array<PulseRay>;
	var collisions: Array<Vec2> = [];
	
	function getPulseProgress()
	{
		return timeSinceLaunch * speed;
	}

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
		for (r in rays)
		{
			r.update(getPulseProgress());
		}
	}

	function generateRays()
	{
		trace("Genrating rays");
		rays = [];
		var nRays = 10;
		var rayLength = 200;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentSize * i;
			var endVec = new Vector(
				(Math.cos(angle) * rayLength) + position.x,
				(Math.sin(angle) * rayLength) + position.y);
			var startVec = new Vector(position.x, position.y);
			var r = new PulseRay(new Ray(startVec, endVec));
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
					if (level.levelData[y][x] == 0) // empty space
						continue;
					
					var wall = Polygon.rectangle(x * level.tileSize, y * level.tileSize, level.tileSize, level.tileSize, false);
					r.checkCollision(wall);
				}
			}
		}
	}

	override public function render(state:GamePlayState)
	{
		super.render(state);
		for (r in rays)
		{
			r.render();
		}
	}
}