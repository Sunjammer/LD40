package coldBoot.states;
import coldBoot.Entity;
import coldBoot.Level;
import coldBoot.entities.ActiveSonar;
import coldBoot.entities.Pulse;
import glm.Vec2;
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
		trace("Entered gameplay state");
		rootEntity = new Entity();
		g.addChild(this);
		
		var level = new Level();
		rootEntity.add(level);
		var sonar = new ActiveSonar();
		sonar.position = new Vec2(60, 60);
		rootEntity.add(sonar);
		var pulse = new Pulse(level);
		pulse.position = new Vec2(60, 60);
		rootEntity.add(pulse);
	}
	
	public function render(g:Game):Void
	{
		rootEntity.render(this);
	}

	public function update(g:Game, dt:Float): IGameState
	{
		rootEntity.update(this, dt);
		return this;
	}

	public function exit(g:Game):Void
	{
		g.removeChild(this);
	}
}