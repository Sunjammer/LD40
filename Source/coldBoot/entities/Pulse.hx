package coldBoot.entities;
import coldBoot.Level;
import coldBoot.UpdateInfo;
import coldBoot.Wall;
import coldBoot.entities.Pulse.Edges;
import coldBoot.states.GamePlayState;
import differ.Collision;
import differ.data.RayCollision;
import differ.math.Vector;
import differ.shapes.Ray;
import glm.Vec2;

class Edges
{
	public var left: Bool;
	public var right: Bool;
	public var top: Bool;
	public var bottom: Bool;

	public function new () { }
}

class Angles 
{
	public static function EdgeFromAngle(angle: Float) : Edges
	{
		var e = 0.1;
		var ret = new Edges();
		if (angle < Math.PI/4 + e || angle > (Math.PI + (3*(Math.PI/4))) - e)
		{
			ret.right = true;
		}
		if (angle > (Math.PI/4) - e && angle < (3 * (Math.PI / 4)) + e)
		{
			ret.top = true;
		}
		if (angle > (3 * (Math.PI / 4)) - e && angle < Math.PI + (Math.PI / 4) + e)
		{
			ret.left = true;
		}
		if (angle > Math.PI + (Math.PI / 4) - e && e < Math.PI + 3 * (Math.PI / 4) + e)
		{
			ret.bottom = true;
		}
		return ret;
	}
	
	public static function AngleInDirectionOfEdge(angle: Float, e: Edges): Bool
	{
		var dir = new Vec2(Math.cos(angle), Math.sin(angle));
		
		if (e.left) return dir.x < 0;
		if (e.right) return dir.x > 0;
		if (e.top) return dir.y < 0;
		if (e.bottom) return dir.y > 0;
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
		pulseProgress = 0;
	}
	
	public function getClosesCollisionPoint(): Vec2
	{
		var x = RayCollisionHelper.hitStartX(closestHit);
		var y = RayCollisionHelper.hitStartY(closestHit);
		return new Vec2(x, y);
	}
	
	public function getEdgeOfLastWallHit(): Edges
	{
		if (lastWallHit != null)
		{
			var hitX = RayCollisionHelper.hitStartX(closestHit);
			var hitY = RayCollisionHelper.hitStartY(closestHit);
			var wallCenter = new Vec2(lastWallHit.x + (lastWallHit.w / 2.0), lastWallHit.y + (lastWallHit.h / 2.0));
			var hit = new Vec2(hitX, hitY);
			var dir = hit - wallCenter;
			var dirNormal = Vec2.normalize(dir, dir);
			var angle = Math.atan2(dirNormal.y, -dirNormal.x);

			return Angles.EdgeFromAngle(angle);
		}
		return new Edges();
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
			trace("Closest hit: " + closestHit.start);
			health -= progressDT * 2 * healthDecay;
			return true;
		}
		return false;
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
	var timeSinceLaunch: Float = 0;
	var level:Level;

	var rays: Array<PulseRay> = [];

	public function new(level: Level)
	{
		super();
		this.level = level;
	}

	override public function onAdded()
	{
		super.onAdded();
		generateRays(position, null, new Edges());
		traceRays();
	}

	override public function update(info:UpdateInfo)
	{
		super.update(info);
		timeSinceLaunch += info.deltaTime;
		var toBeRemoved = [];
		for (r in rays)
		{
			if (r.update(timeSinceLaunch))
			{
				var lastEdgeHit = r.getEdgeOfLastWallHit();
				toBeRemoved.push(r);
				generateRays(r.getClosesCollisionPoint(), r.lastWallHit, lastEdgeHit, r.health);
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

	function generateRays(pos: Vec2, ignoreWall: Wall, edges: Edges, health: Float = 10)
	{
		trace("Genrating rays");
		var nRays = 1;
		var rayLength = 200;
		var segmentOffset = 1.5523;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentOffset + segmentSize * i;
			if (Angles.AngleInDirectionOfEdge(angle, edges))
				continue;
			var endVec = new Vector(
				(Math.cos(angle) * rayLength) + pos.x,
				(Math.sin(angle) * rayLength) + pos.y);
			var startVec = new Vector(pos.x, pos.y);
			var r = new PulseRay(new Ray(startVec, endVec), speed, timeSinceLaunch, ignoreWall, health);
			rays.push(r);
		}
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

	override public function render(info:RenderInfo)
	{
		super.render(info);
		for (r in rays)
		{
			r.render();
		}
	}
}