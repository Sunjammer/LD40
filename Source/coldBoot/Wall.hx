package coldBoot;
import differ.shapes.Polygon;
import differ.shapes.Shape;

class Wall 
{
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;
	
	public function new(x: Float, y: Float, w: Float, h: Float) 
	{
		this.h = h;
		this.w = w;
		this.y = y;
		this.x = x;
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