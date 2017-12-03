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
	var level: Level;
	
	public function new() 
	{
		super();
	}

	public function enter(g:Game):Void
	{
		trace("Entered gameplay state");
		rootEntity = new Entity();
		g.addChild(this);
		
		level = new Level();
		rootEntity.add(level);
		var sonar = new ActiveSonar();
		sonar.position = new Vec2(90, 90);
		rootEntity.add(sonar);
		var pulse = new Pulse(level);
		pulse.position = new Vec2(90, 90);
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
	
	public function pulse(pos: Vec2)
	{
		trace("We are pulsing");
		var pulse = new Pulse(level);
		pulse.position = pos;
		rootEntity.add(pulse);
	}
	
}