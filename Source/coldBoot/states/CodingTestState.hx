package coldboot.states;
import coldboot.codinghell.Terminal;
import coldboot.Entity;
import coldboot.UpdateInfo;
import coldboot.Game;
import coldboot.IGameState;
import coldboot.RenderInfo;
import openfl.display.Sprite;

/**
 * ...
 * @author Andreas Kennedy
 */
class CodingTestState extends Sprite implements IGameState {
	var terminal:coldboot.codinghell.Terminal;

  public function new() {
    super();
  }
  
  
  /* INTERFACE coldboot.IGameState */
  
  public function render(info:RenderInfo):Void {
    
  }
  
  public function enter(g:Game, ?args:Dynamic):Void {
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
  
  
  /* INTERFACE coldboot.IGameState */
  
  public function addChildEntity(e:Entity):Void 
  {
	  
  }
  
  public function removeChildEntity(e:Entity):Void 
  {
	  
  }
  
  
  /* INTERFACE coldboot.IGameState */
  
  public function getRootEntity():Entity 
  {
	return null;
  }
  
}