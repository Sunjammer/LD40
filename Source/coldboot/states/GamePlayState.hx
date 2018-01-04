package coldboot.states;
import coldboot.codinghell.Terminal;
import coldboot.Audio.AudioCommand;
import coldboot.Entity;
import coldboot.Game;
import coldboot.IState;
import coldboot.IGameState;
import coldboot.Level;
import coldboot.RenderInfo;
import coldboot.UpdateInfo;
import coldboot.entities.Base;
import coldboot.entities.Enemy;
import coldboot.entities.PulseMap;
import coldboot.entities.Turret;
import glm.Vec2;
import openfl.display.DisplayObjectContainer;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import openfl.utils.Timer;
import openfl.Assets;
import coldboot.rendering.opengl.Symbology;
//import haxe.Timer;

class WaveCompletedState implements IState {
  public function new () {}

  public function enter(g:Game, ?args:Dynamic):Void {

  }

  public function update(info:UpdateInfo): IState {
    return this;
  }

  public function exit(g:Game):Void {

  }
}

class WaveState implements IState {
  var nEnemies: Int;
  var difficulty: Float;
  var enemySpawnPoint:Vec2;
  var level:Level;
  var pulseMap:PulseMap;
  var container:DisplayObjectContainer;
  var enemiesSpawned:Int;
  var timer:Timer;

  public function new(pulseMap:PulseMap, container: DisplayObjectContainer, level: Level, enemySpawnPoint: Vec2, nEnemies: Int) {
    enemiesSpawned = 0; //remember to init numbers for non-cpp targets
    this.nEnemies = nEnemies;
    this.pulseMap = pulseMap;
    this.level = level;
    this.enemySpawnPoint = enemySpawnPoint;
    this.container = container;
    timer = new Timer(1000, nEnemies);
  }

  public function enter(g:Game, ?args:Dynamic):Void {
    var root = g.getCurrentState().getRootEntity();
    //Timer.delay(container.dispatchEvent() ;
    timer.addEventListener("timer", function(data:Dynamic) {
      var enemy = new Enemy(pulseMap, level, enemySpawnPoint * (level.pixelSize * 3) - (level.pixelSize * 3) / 2 + 1);
      enemy.addTag("enemy");
      root.add(enemy);
      ++enemiesSpawned;
    });
    timer.start();
  }

  public function update(info:UpdateInfo):IState {
    var enemies = info.game.getCurrentState().getRootEntity().getChildEntitiesByTag("enemy");
    if (enemies.length == 0 && enemiesSpawned == nEnemies) {
      trace("Wave completed");
      return new WaveCompletedState();
    }
    return this;
  }

  public function exit(g:Game):Void {
    timer.stop();
  }
}

@:build(coldboot.rendering.opengl.GLDebug.build())
class GamePlayState extends DisplayObjectContainer implements IGameState {
  var terminal:Terminal;
  public var rootEntity: Entity;
  var level: Level;

  var waveState: IState;

  public function new() {
    super();
  }

  public function enter(g:Game, ?args:Dynamic):Void {
    g.audio.exec(AudioCommand.PlaySound(SampleId.SAMPLE_ID_SONAR_ECHO, 0, 0));
    
    g.stateSpriteContainer.addChild(this);
    g.viewportChanged.add(onViewportChanged);

    rootEntity = new Entity();

    terminal = new Terminal(g);

    var enemySpawnPoint = new glm.Vec2(1,1);
    level = new Level(this, enemySpawnPoint);

    /*var pulseMap = new PulseMap(level);
    pulseMap.addTag("pulseMap");

    waveState = new WaveState(pulseMap, this, level, enemySpawnPoint, 40);

    var base = new Base(100);
    base.position = new Vec2(150, 150);

    var turret = new Turret();
    turret.position = new Vec2(200, 200);

    rootEntity.add(pulseMap);
    rootEntity.add(base);
    rootEntity.add(turret);
*/
    rootEntity.add(level);

    //addChild(new Bitmap(Assets.getBitmapData("assets/c1.jpg")));

    addChild(terminal);

    //waveState.enter(g);

    stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  function onMouseDown(e:MouseEvent):Void {
    var px = stage.mouseX / stage.stageWidth * 2 - 1;
    var py = stage.mouseY / stage.stageHeight * 2 - 1;
    Audio.getInstance().exec(AudioCommand.PlaySound(SampleId.SAMPLE_ID_SONAR_ECHO, px, py));
  }

  function onViewportChanged(w:Int, h:Int):Void {
	  terminal.updateUi(w,h,20);
  }

  @gldebug
  public function render(info:RenderInfo):Void {
    rootEntity.render(info);
    Symbology.draw(info.viewport.width, info.viewport.height);
  }

  var timer = 0.0;
  public function update(info:UpdateInfo): IGameState {
    Symbology.beginFrame();

    var hw = (info.game.renderInfo.viewport.width - 220) / 2;
    var hh = info.game.renderInfo.viewport.height / 2;

    Symbology.point(hw, hh, 4);
    Symbology.triangle(hw, hh, 100, 75, 0, true, 0.5);
    Symbology.square(hw, hh, 200, 200, Math.cos(info.time));
    Symbology.square(hw, hh, 200, 200, Math.cos(info.time+0.1), 0.8);
    Symbology.square(hw, hh, 200, 200, Math.cos(info.time+0.2), 0.6);
    Symbology.square(hw, hh, 200, 200, Math.cos(info.time+0.3), 0.4);
    Symbology.circle(hw, hh, 300);
    /*rootEntity.update(info);
    waveState.update(info);

    timer += info.deltaTime;
    if (timer > 5.0)
    {
    	trace("Pulsing");
    	var pulseMap: PulseMap = cast rootEntity.getChildEntitiesByTag("pulseMap")[0];
    	pulseMap.startPulse(10, 1, 40, 0);
    	timer = 0;
    }
    */
    return this;
  }

  public function exit(g:Game):Void {
    g.viewportChanged.remove(onViewportChanged);
    g.stateSpriteContainer.removeChild(this);
    waveState.exit(g);
  }

  /* INTERFACE coldboot.IGameState */

  public function getRootEntity():Entity {
    return this.rootEntity;
  }

}