package coldBoot.states;
import coldBoot.IGameState;
import codinghell.CodingHell;
import coldBoot.Entity;
import coldBoot.Game;
import coldBoot.IState;
import coldBoot.RenderInfo;
import coldBoot.Level;
import coldBoot.UpdateInfo;
import coldBoot.entities.ActiveSonar;
import coldBoot.entities.Base;
import coldBoot.entities.Enemy;
import coldBoot.entities.Pulse;
import coldBoot.entities.Turret;
import coldBoot.states.GamePlayState.WaveState;
import glm.Vec2;
import openfl.display.DisplayObjectContainer;

class WaveState implements IState
{
	var nEnemies: Int;
	var difficulty: Float;
	var enemySpawnPoint:Vec2;
	var level:Level;
	
	public function new(level: Level, enemySpawnPoint: Vec2)
	{
		this.level = level;
		this.enemySpawnPoint = enemySpawnPoint;
	}
	
	public function enter(g:Game):Void 
	{
		var root = g.getCurrentState().getRootEntity();
		
		for (i in 0...50) {
			var enemy = new Enemy(level, enemySpawnPoint * (level.pixelSize * 3) - (level.pixelSize * 3) / 2 + 1);
			enemy.addTag("enemy");
			root.add(enemy);
		}
	}
	
	public function update(info:UpdateInfo):IState 
	{ 
		return this;
	}
	
	public function exit(g:Game):Void 
	{
		
	}
}

class GamePlayState extends DisplayObjectContainer implements IGameState
{
  var terminal:CodingHell;
	public var rootEntity: Entity;
	var level: Level;
	
	var waveState: IState;
	
	public function new()
	{
		super();
	}

	public function enter(g:Game):Void
	{
		rootEntity = new Entity();

        		
        terminal = new CodingHell(200);
        addChild(terminal);
    
		var enemySpawnPoint = new glm.Vec2(1,1);
		level = new Level(enemySpawnPoint);
		rootEntity.add(level);
		
		waveState = new WaveState(level, enemySpawnPoint);
		
		var base = new Base(100);
		base.position = new Vec2(150, 150);
		rootEntity.add(base);
	
		var turret = new Turret();
		turret.position = new Vec2(200, 200);
		rootEntity.add(turret);
	   
		g.spriteContainer.addChild(this);
		
		waveState.enter(g);
	}
	
	public function render(info:RenderInfo):Void
	{
		rootEntity.render(info);
	}

	public function update(info:UpdateInfo): IGameState
	{
		rootEntity.update(info);
		waveState.update(info);
		return this;
	}
	
	public function exit(g:Game):Void
	{
		g.spriteContainer.removeChild(this);
		waveState.exit(g);
	}
	
	
	/* INTERFACE coldBoot.IGameState */
	
	public function getRootEntity():Entity 
	{
		return this.rootEntity;
	}
	
}