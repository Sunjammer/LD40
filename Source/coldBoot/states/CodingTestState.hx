package coldBoot.states;
import codinghell.CodingHell;
import coldBoot.Entity;
import coldBoot.UpdateInfo;
import coldBoot.Game;
import coldBoot.IGameState;
import coldBoot.RenderInfo;
import openfl.display.Sprite;

/**
 * ...
 * @author Andreas Kennedy
 */
class CodingTestState extends Sprite implements IGameState {

  public function new() {
    super();
    var terminal = new CodingHell(300);
    addChild(terminal);
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function render(info:RenderInfo):Void {
    
  }
  
  public function enter(g:Game):Void {
    g.spriteContainer.addChild(this);
  }
  
  public function update(info:UpdateInfo):IGameState {
    return this;
  }
  
  public function exit(g:Game):Void {
    g.spriteContainer.removeChild(this);
    
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function addChildEntity(e:Entity):Void 
  {
	  
  }
  
  public function removeChildEntity(e:Entity):Void 
  {
	  
  }
  
}