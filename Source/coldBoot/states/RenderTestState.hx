package coldBoot.states;
import coldBoot.UpdateInfo;
import coldBoot.IState;
import coldBoot.Game;
import coldBoot.Entity;
import coldBoot.IGameState;
import coldBoot.RenderInfo;
import glm.Vec2;

/**
 * ...
 * @author Andreas Kennedy
 */
class RenderTestState implements IGameState {
  var level:coldBoot.Level;

  public function new() {
    level = new Level(new Vec2(2,2));
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function render(info:RenderInfo):Void {
     level.render(info);
  }
  
  public function getRootEntity():Entity {
    return null;
  }
  
  public function enter(g:Game):Void {
    
  }
  
  public function update(info:UpdateInfo):IState {
    return this;
  }
  
  public function exit(g:Game):Void {
    
  }

}