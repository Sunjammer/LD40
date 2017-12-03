package coldBoot;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import glm.Vec2;

class Wall 
{
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;
	
	public var pos: Vec2;
	
	public function new(x: Float, y: Float, w: Float, h: Float) 
	{
		this.h = h;
		this.w = w;
		this.y = y;
		this.x = x;
		pos = new Vec2(x, y);
	}
	
	public function getPolygon(): Shape
	{
		return Polygon.rectangle(x, y, w, h, false);
	}
	
	public function render()
	{
		Main.debugDraw.graphics.drawRect(x, y, w, h);
	}
}