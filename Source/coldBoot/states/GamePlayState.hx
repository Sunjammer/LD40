package coldBoot.states;
import codinghell.CodingHell;
import coldBoot.Entity;
import coldBoot.Game;
import coldBoot.IGameState;
import coldBoot.IState;
import coldBoot.Level;
import coldBoot.RenderInfo;
import coldBoot.UpdateInfo;
import coldBoot.entities.Base;
import coldBoot.entities.Enemy;
import coldBoot.entities.PulseMap;
import coldBoot.entities.Turret;
import glm.Vec2;
import openfl.display.DisplayObjectContainer;

class WaveCompletedState implements IState
{
	public function new () {}
	
	public function enter(g:Game):Void 
	{
		
	}
	
	public function update(info:UpdateInfo): IState 
	{
		return this;
	}
	
	public function exit(g:Game):Void 
	{
		
	}
}

class WaveState implements IState
{
	var nEnemies: Int;
	var difficulty: Float;
	var enemySpawnPoint:Vec2;
	var level:Level;
	
	public function new(level: Level, enemySpawnPoint: Vec2, nEnemies: Int)
	{
		this.nEnemies = nEnemies;
		this.level = level;
		this.enemySpawnPoint = enemySpawnPoint;
	}
	
	public function enter(g:Game):Void 
	{
		var root = g.getCurrentState().getRootEntity();
		
		for (i in 0...nEnemies) {
			var enemy = new Enemy(level, enemySpawnPoint * (level.pixelSize * 3) - (level.pixelSize * 3) / 2 + 1);
			enemy.addTag("enemy");
			root.add(enemy);
		}
	}
	
	public function update(info:UpdateInfo):IState 
	{
		var enemies = info.game.getCurrentState().getRootEntity().getChildEntitiesByTag("enemy");
		if (enemies.length == 0)
		{
			trace("Wave completed");
			return new WaveCompletedState();
		}
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
		
		var pulseMap = new PulseMap(level);
		pulseMap.addTag("pulseMap");
		rootEntity.add(pulseMap);
		
		waveState = new WaveState(level, enemySpawnPoint, 5);
		
		var base = new Base(100);
		base.position = new Vec2(150, 150);
		rootEntity.add(base);
	
		/*var turret = new Turret();
		turret.position = new Vec2(200, 200);
		rootEntity.add(turret);*/
	   
		g.spriteContainer.addChild(this);
		
		waveState.enter(g);
		
		
		pulseMap.startPulse(10, 4, 80, 0);
		pulseMap.startPulse(16, 15, 90, 1);

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