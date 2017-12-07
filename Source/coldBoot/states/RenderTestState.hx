package coldboot.states;
import coldboot.UpdateInfo;
import coldboot.IState;
import coldboot.Game;
import coldboot.Entity;
import coldboot.IGameState;
import coldboot.RenderInfo;
import glm.Vec2;

/**
 * ...
 * @author Andreas Kennedy
 */
class RenderTestState implements IGameState {
  var level:coldboot.Level;

  public function new() {
    level = new Level(new Vec2(2,2));
  }
  
  
  /* INTERFACE coldboot.IGameState */
  
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