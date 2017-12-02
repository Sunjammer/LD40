package coldBoot;
import coldBoot.IGameState;
import coldBoot.rendering.PostEffect;
import coldBoot.rendering.SceneRenderBase;
import coldBoot.states.InitialState;
import openfl.display.Sprite;
import tween.Delta;

class Game extends Sprite
{
	var currentState: IGameState;

  var sceneRenderer:SceneRenderBase;
  
	public function new()
	{
		super();
		setState(new InitialState());
    
    addChild(sceneRenderer = new SceneRenderBase({width:800, height:600}));
    sceneRenderer.setPostEffects(
      [
        //new PostEffect("assets/invert.frag"),
        //new PostEffect("assets/scanline.frag")
      ]
    );
      
	}
  

	public function update(dt: Float)
	{
		Delta.step(dt);
		sceneRenderer.update(this, dt);
	}

 #if !display
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