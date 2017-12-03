package coldBoot.states;
import codinghell.CodingHell;
import coldBoot.Entity;
import coldBoot.RenderInfo;
import coldBoot.Level;
import coldBoot.UpdateInfo;
import coldBoot.entities.ActiveSonar;
import coldBoot.entities.Base;
import coldBoot.entities.Enemy;
import coldBoot.entities.Pulse;
import coldBoot.entities.Turret;
import glm.Vec2;
import openfl.display.DisplayObjectContainer;

class GamePlayState extends DisplayObjectContainer implements IGameState
{
  var terminal:CodingHell;
	public var rootEntity: Entity;
	var level: Level;
	
	public function new()
	{
		super();
	}

	public function enter(g:Game):Void
	{
		rootEntity = new Entity();

        		
	terminal = new CodingHell(g, 400);
        addChild(terminal);
    
		var enemySpawnPoint = new glm.Vec2(1,1);
		level = new Level(enemySpawnPoint);
		rootEntity.add(level);
		
		var base = new Base(100);
		base.position = new Vec2(150, 150);
		rootEntity.add(base);
	
		var turret = new Turret();
		turret.position = new Vec2(200, 200);

		rootEntity.add(turret);
		
		for (i in 0...50) {
			var enemy = new Enemy(level, enemySpawnPoint * (level.pixelSize * 3) - (level.pixelSize * 3) / 2 + 1);
			enemy.addTag("enemy");
			rootEntity.add(enemy);
		}
	   
		g.spriteContainer.addChild(this);
		g.viewportChanged.add(onViewportChanged);
	}
  
	function onViewportChanged(w:Int, h:Int):Void {
		trace("Viewport changed");
		terminal.x = w - 400;
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
		g.viewportChanged.remove(onViewportChanged);
		g.spriteContainer.removeChild(this);
	}
	
	
	/* INTERFACE coldBoot.IGameState */
	
	public function getRootEntity():Entity 
	{
		return this.rootEntity;
	}
	
}