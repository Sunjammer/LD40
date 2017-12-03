package coldBoot.states;
import coldBoot.Entity;
import coldBoot.RenderInfo;
import coldBoot.Level;
import coldBoot.UpdateInfo;
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
		rootEntity = new Entity();
		
		level = new Level();
		rootEntity.add(level);
		var sonar = new ActiveSonar();
		sonar.position = new Vec2(90, 90);
		rootEntity.add(sonar);
		var pulse = new Pulse(level);
		pulse.position = new Vec2(90, 90);
		rootEntity.add(pulse);
		g.addChild(this);
	}
	
	public function render(info:RenderInfo):Void
	{
		rootEntity.render(info);
	}

	public function update(info:UpdateInfo): IGameState
	{
		rootEntity.update(info);
		return this;
	}

	public function exit(g:Game):Void
	{
		g.removeChild(this);
	}
}