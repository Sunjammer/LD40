package coldBoot;
import coldBoot.IGameState;
#if ogl
import coldBoot.rendering.PostEffect;
import coldBoot.rendering.SceneRenderBase;
#end
import coldBoot.UpdateInfo;
import coldBoot.states.InitialState;
import openfl.display.Sprite;
import tween.Delta;

import haxe.ds.Option;

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
        new PostEffect("assets/invert.frag")
      ]
    );
    #end
      
	}
  
  public function getCurrentState():IGameState{
    return currentState;
  }
  

	public function update(dt:Float)
	{
    var info = {game:this, deltaTime:dt, time:0.0};
		Delta.step(info.deltaTime);
    #if ogl
		sceneRenderer.update(this, info.deltaTime);
    #end
    if (currentState != null)
      currentState.update(info);
	}

 #if (!display && ogl)
  override function __renderGL(renderSession):Void {
    sceneRenderer.preRender();
		currentState.render({game:this});
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