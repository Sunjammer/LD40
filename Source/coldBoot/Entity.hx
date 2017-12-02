package coldBoot;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;
import glm.Vec2;

class Entity
{
	public var position: Vec2 = new Vec2(0,0);
	public var rotation: Float = 0;

	public var children:Array<Entity>;
	public function new()
	{
		children = [];
	}

	public function add(e:Entity):Void
	{
		children.push(e);
		e.onAdded();
	}

	public function remove(e:Entity):Void
	{
		children.remove(e);
		e.onRemoved();
	}

	public function onAdded()
	{

	}

	public function onRemoved()
	{

	}

	public function update(info:UpdateInfo)
	{
		for (c in children)
			c.update(info);
	}

	public function render(info:RenderInfo)
	{
		for (c in children)
			c.render(info);
	}

}