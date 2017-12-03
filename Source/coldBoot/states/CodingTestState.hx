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
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function render(info:RenderInfo):Void {
    
  }
  
  public function enter(g:Game):Void {
    g.stateSpriteContainer.addChild(this);
    var terminal = new CodingHell(g, 300);
    addChild(terminal);
  }
  
  public function update(info:UpdateInfo):IGameState {
    return this;
  }
  
  public function exit(g:Game):Void {
    g.stateSpriteContainer.removeChild(this);
    
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function addChildEntity(e:Entity):Void 
  {
	  
  }
  
  public function removeChildEntity(e:Entity):Void 
  {
	  
  }
  
}