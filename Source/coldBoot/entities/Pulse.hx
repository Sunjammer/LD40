package coldBoot.entities;
import coldBoot.Level;
import coldBoot.states.GamePlayState;
import differ.Collision;
import differ.math.Vector;
import differ.shapes.Ray;
import glm.Vec2;

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 1;
	var timeSinceLaunch: Float;
	var level:Level;
	
	public function new(level: Level)
	{
		super();
		this.level = level;
	}
	
	override public function onAdded()
	{
		super.onAdded();
	}
	
	override public function update(state:GamePlayState, dt:Float) 
	{
		super.update(state, dt);
		timeSinceLaunch += dt;
	}
	
	public function fire(position: Vec2)
	{
		generateRays();
	}
	
	function generateRays(): Array<Ray>
	{
		var rays = [];
		var nRays = 20;
		var segmentSize = 2 * Math.PI / nRays;
		for (i in 0...nRays)
		{
			var angle = segmentSize * i;
			var endVec = new Vector(Math.cos(angle), Math.sin(angle));
			var r = new Ray(new Vector(position.x, position.y), endVec);
			rays.push(r);
		}
		return rays;		
	}
	
}