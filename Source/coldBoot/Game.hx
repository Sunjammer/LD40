package coldBoot;
import coldBoot.IGameState;
#if ogl
import coldBoot.rendering.PostEffect;
import coldBoot.rendering.SceneRenderBase;
#end
import coldBoot.states.InitialState;
import openfl.display.Sprite;
import tween.Delta;

class Game extends Sprite
{
	var currentState: IGameState;

  #if ogl
  var sceneRenderer:SceneRenderBase;
  #end
  
	public function new()
	{
		super();
		setState(new InitialState());
    
    #if ogl
    addChild(sceneRenderer = new SceneRenderBase({width:800, height:600}));
    sceneRenderer.setPostEffects(
      [
        new PostEffect("assets/scanline.frag")
      ]
    );
    #end
      
	}
  

	public function update(dt: Float)
	{
		Delta.step(dt);
    #if ogl
		sceneRenderer.update(this, dt);
    #end
	}

 #if (!display && windows)
  override function __renderGL(renderSession):Void {
    sceneRenderer.preRender();
		currentState.render(this);
    super.__renderGL(renderSession);
  }
 #end

	public function setState(s:IGameState): IGameState
	{
		if (currentState != null)
		{
			currentState.exit(this);
		}
		currentState = s;
		currentState.enter(this);
		return currentState;
	}

}