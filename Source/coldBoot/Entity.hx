package coldBoot;
import coldBoot.states.GamePlayState;
import glm.Vec2;

class Entity
{
	var position: Vec2;
	var rotation: Float;

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

	public function update(state:GamePlayState, dt:Float)
	{
		for (c in children)
			c.update(state, dt);
	}

	public function render(state:GamePlayState)
	{
		for (c in children)
			c.render(state);
	}

}