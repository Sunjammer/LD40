package coldBoot.states;
import coldBoot.Entity;
import openfl.display.DisplayObjectContainer;

class GamePlayState extends DisplayObjectContainer implements IGameState
{
	public var rootEntity: Entity;
	
	public function new() 
	{
		super();
	}

	public function enter(g:Game):Void
	{
    rootEntity = new Entity();
		g.addChild(this);
	}
	
	public function render(g:Game):Void
	{
		rootEntity.render(this);
	}

	public function update(g:Game, dt:Float):IGameState
	{
		rootEntity.update(this, dt);
	}

	public function exit(g:Game):Void
	{
		g.removeChild(this);
	}
}