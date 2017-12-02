package coldBoot.entities;
import coldBoot.Level;
import coldBoot.Wall;
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
	public static function EdgeFromAngle(angle: Float) : Edge
	{
		if (angle < Math.PI/4 || angle > (Math.PI + (3*(Math.PI/4))))
		{
			return Edge.Right;
		}
		else if (angle > (Math.PI/4) && angle < (3 * (Math.PI / 4)))
		{
			return Edge.Top;
		}
		else if (angle > (3 * (Math.PI / 4)) && angle < Math.PI + (Math.PI / 4))
		{
			return Edge.Left;
		}
		else
		{
			return Edge.Bottom;
		}
	}
	
	public static function AngleInDirectionOfEdge(angle: Float, e: Edge): Bool
	{
		var dir = new Vec2(Math.cos(angle), Math.sin(angle));
		switch (e) 
		{
			case Left: return dir.x < 0;
			case Right: return dir.x > 0;
			case Top: return dir.y < 0;
			case Bottom: return dir.y > 0;
			case _: return false;
		}
	}
	
}

class PulseRay
{
	var ray: Ray;
	var speed: Float;
	var closestHit: RayCollision;
	var pulseProgress: Float;
	var rayStartOffset: Float;
	public var lastWallHit:Wall;
	var ignoreWall:Wall;
	
	public function new(r: Ray, speed: Float, startOffet: Float, ignoreWall: Wall)
	{
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
	
	public function getEdgeOfLastWallHit(): Edge
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
		this.pulseProgress = (progress - rayStartOffset) * speed;
		if (closestHit != null && pulseProgress > closestHit.start)
		{
			trace("Closest hit: " + closestHit.start);
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
		generateRays(position, null, Edge.None);
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
				var lastEdgeHit = r.getEdgeOfLastWallHit();
				toBeRemoved.push(r);
				generateRays(r.getClosesCollisionPoint(), r.lastWallHit, lastEdgeHit);
				traceRays();
			}
		}
		for (r in toBeRemoved)
			rays.remove(r);
	}

	function generateRays(pos: Vec2, ignoreWall: Wall, edge: Edge)
	{
		trace("Genrating rays");
		var nRays = 1;
		var rayLength = 200;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentSize * i;
			if (Angles.AngleInDirectionOfEdge(angle, edge))
				continue;
			var endVec = new Vector(
				(Math.cos(angle) * rayLength) + pos.x,
				(Math.sin(angle) * rayLength) + pos.y);
			var startVec = new Vector(pos.x, pos.y);
			var r = new PulseRay(new Ray(startVec, endVec), speed, timeSinceLaunch, ignoreWall);
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

	override public function render(state:GamePlayState)
	{
		super.render(state);
		for (r in rays)
		{
			r.render();
		}
	}
}