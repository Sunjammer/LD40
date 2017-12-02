package coldBoot.entities;
import coldBoot.Level;
import coldBoot.Wall;
import coldBoot.entities.Pulse.Edge;
import coldBoot.states.GamePlayState;
import differ.Collision;
import differ.data.RayCollision;
import differ.math.Vector;
import differ.shapes.Ray;
import glm.Vec2;

enum Edge
{
	Left;
	Right;
	Top;
	Bottom;
	None;
}

class Angles
{
	public static function AngleToEdge(angle: Float): Edge
	{

		angle += Math.PI / 4;
		angle = angle % (Math.PI * 2);

		if (angle >= 0 && angle < Math.PI / 2.0)
			return Edge.Right;
		if (angle >= Math.PI / 2.0 && angle < Math.PI)
			return Edge.Bottom;
		if (angle >= Math.PI && angle < Math.PI + Math.PI/2.0)
			return Edge.Left;
		else {
			return Edge.Top;
		}
	}

	public static function AngleInDirectionOfEdge(angle: Float, e: Edge): Bool
	{
		var dir = new Vec2(Math.cos(angle), Math.sin(angle));
		if (e == Edge.Left && dir.x > 0)
			return true;
		if (e == Edge.Right && dir.x < 0)
			return true;
		if (e == Edge.Top && dir.y > 0)
			return true;
		if (e == Edge.Bottom && dir.y < 0)
			return true;
		return false;
	}
}

class PulseRay
{
	var ray: Ray;
	var speed: Float;
	var closestHit: RayCollision;
	var pulseProgress: Float;
	var rayStartOffset: Float;

	public var healthDecay: Float = 20;
	public var health:Float;
	public var lastWallHit:Wall;
	var ignoreWall:Wall;

	public function new(r: Ray, speed: Float, startOffet: Float, ignoreWall: Wall, health: Float)
	{
		this.health = health;
		this.ignoreWall = ignoreWall;
		this.ray = r;
		this.speed = speed;
		this.rayStartOffset = startOffet;
	}

	public function getClosesCollisionPoint(): Vec2
	{
		var x = RayCollisionHelper.hitStartX(closestHit);
		var y = RayCollisionHelper.hitStartY(closestHit);
		return new Vec2(x, y);
	}
	
	public function getReflectionVector(): Vec2
	{
		var original = new Vec2(ray.dir.x, ray.dir.y);
		trace("Original: " + original);
		var edgeHit = getEdgeOfLastWallHit();
		switch (edgeHit)
		{
			case Edge.Left | Edge.Right: return new Vec2( -original.x, original.y);
			case Edge.Top | Edge.Bottom: return new Vec2( original.x, -original.y);
			case _: throw "hax er dust";
		}
		return new Vec2();
	}

	public function getEdgeOfLastWallHit(): Edge
	{
		if (lastWallHit != null)
		{
			var hitX = RayCollisionHelper.hitStartX(closestHit);
			var hitY = RayCollisionHelper.hitStartY(closestHit);
			var hit = new Vec2(hitX, hitY);
			var boxOrigin = new Vec2(lastWallHit.x, lastWallHit.y);
			var boxSize = new Vec2(lastWallHit.w, lastWallHit.h);

			var boxRelativeHit = Vec2.subtractVecOp(hit, boxOrigin);
			var scaledBoxRelativeHit =  new Vec2(boxRelativeHit.x / boxSize.x, boxRelativeHit.y / boxSize.y);
			var scaledBoxCenter = new Vec2(0.5, 0.5);
			var centerRelativeHit = Vec2.subtractVecOp(scaledBoxRelativeHit, scaledBoxCenter);

			var angle = Math.atan2(centerRelativeHit.y, centerRelativeHit.x) + (Math.PI * 2);

			var ret = Angles.AngleToEdge(angle);
			return ret;
		}
		return Edge.None;
	}

	public function checkCollision(wall: Wall)
	{
		if (wall == ignoreWall)
			return;
		var w = wall.getPolygon();
		var collideInfo  = Collision.rayWithShape(ray, w);
		if (collideInfo != null)
		{
			if (closestHit == null)
			{
				closestHit = collideInfo;
				lastWallHit = wall;
			}
			else if (collideInfo.start < closestHit.start)
			{
				closestHit = collideInfo;
				lastWallHit = wall;
			}
		}
	}

	public function update(progress: Float): Bool
	{
		var newProgress = (progress - rayStartOffset) * speed;
		var progressDT = newProgress - pulseProgress;
		pulseProgress = newProgress;
		health -= progressDT * healthDecay;
		//trace("Health: " + health);
		if (closestHit != null && pulseProgress > closestHit.start)
		{
			health -= progressDT * 4 * healthDecay;
			return true;
		}
		return false;
	}

	public function render()
	{
		Main.debugDraw.graphics.lineStyle(1, 0x0000ff);
		Main.debugDraw.graphics.moveTo(ray.start.x, ray.start.y);

		var start = new Vec2(ray.start.x, ray.start.y);
		var end = new Vec2(ray.end.x, ray.end.y);
		var outRay = new Vec2();
		var pulseRayPos = Vec2.lerp(start, end, pulseProgress, outRay);
		
		Main.debugDraw.graphics.lineTo(pulseRayPos.x, pulseRayPos.y);
		
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
	var timeSinceLaunch: Float = 0;
	var level:Level;
	
	var segmentOffset: Float = 0;

	var rays: Array<PulseRay> = [];

	public function new(level: Level)
	{
		super();
		this.level = level;
	}

	override public function onAdded()
	{
		super.onAdded();
		generateOriginalRays();
		traceRays();
	}

	override public function update(state:GamePlayState, dt:Float)
	{
		super.update(state, dt);
		timeSinceLaunch += dt;
		var toBeRemoved = [];
		for (r in rays)
		{
			if (r.update(timeSinceLaunch))
			{
				toBeRemoved.push(r);
				generateRays(r);
				traceRays();
			}
			if (r.health <= 0)
			{
				toBeRemoved.push(r);
			}
		}
		for (r in toBeRemoved)
			rays.remove(r);
	}
	
	function generateOriginalRays()
	{
		var health = 20;
		
		var pos = position;
		
		var nRays = 5;
		var rayLength = 200;
		segmentOffset = 0.5;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentOffset + segmentSize * i;
			var endVec = new Vector(
				(Math.cos(angle) * rayLength) + pos.x,
				(Math.sin(angle) * rayLength) + pos.y);
			var startVec = new Vector(pos.x, pos.y);
			var r = new PulseRay(new Ray(startVec, endVec), speed, timeSinceLaunch, null, health);
			rays.push(r);
		}
	}

	function generateRays(originRay: PulseRay)
	{
		var rayLength = 200;
		
		var pos = originRay.getClosesCollisionPoint();
		var ignoreWall = originRay.lastWallHit;
		
		//var edge = originRay.getEdgeOfLastWallHit();

		var reflectionRay = originRay.getReflectionVector();
		reflectionRay = Vec2.normalize(reflectionRay, reflectionRay);
		
		var reflectionRayAngle = Math.atan2(reflectionRay.y, reflectionRay.x);
		var angle = reflectionRayAngle;
/*		if (Angles.AngleInDirectionOfEdge(angle, edge))
			return;*/
		var endVec = new Vector(
			(Math.cos(angle) * rayLength) + pos.x,
			(Math.sin(angle) * rayLength) + pos.y);
		var startVec = new Vector(pos.x, pos.y);
		var r = new PulseRay(new Ray(startVec, endVec), speed, timeSinceLaunch, ignoreWall, originRay.health);
		rays.push(r);
	}

	function traceRays()
	{
		for (r in rays)
		{
			for (w in level.levelData)
			{
				r.checkCollision(w);
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