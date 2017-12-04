package coldBoot.states;
import codinghell.Terminal;
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
	var terminal:codinghell.Terminal;

  public function new() {
    super();
  }
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function render(info:RenderInfo):Void {
    
  }
  
  public function enter(g:Game):Void {
    g.stateSpriteContainer.addChild(this);
    terminal = new Terminal(g, 300);
    addChild(terminal);
	g.viewportChanged.add(onViewportChanged);
	terminal.updateUi();
  }

function onViewportChanged(w:Int, h:Int):Void
{
	trace("Viewport changed");
	terminal.updateUi();
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
  
  
  /* INTERFACE coldBoot.IGameState */
  
  public function getRootEntity():Entity 
  {
	return null;
  }
  
}