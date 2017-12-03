package coldBoot;
import coldBoot.IGameState;
import coldBoot.states.GamePlayState;

#if ogl
	import coldBoot.rendering.PostEffect;
	import coldBoot.rendering.SceneRenderBase;
#end

import coldBoot.states.InitialState;
import glm.Vec2;
import openfl.display.Sprite;
import tween.Delta;

class Game extends Sprite
{
	var currentState: IGameState;

	#if ogl
		var sceneRenderer:SceneRenderBase;
	#end

	public function new(config: {width:Int, height:Int})
	{
		super();
		setState(new InitialState());

		#if ogl
		addChild(sceneRenderer = new SceneRenderBase(config));
		sceneRenderer.setPostEffects(
			[
				new PostEffect("assets/invert.frag")
			]
		);
		#end

	}

	public function resize(dims: {width:Int, height:Int})
	{
		sceneRenderer.setWindowSize(dims);
	}

	public function getCurrentState():IGameState
	{
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
	override function __renderGL(renderSession):Void
	{
		sceneRenderer.preRender();
		currentState.render({game:this});
		super.__renderGL(renderSession);
	}
	#end

	#if !ogl
	public function render(dt:Float)
	{
		currentState.render({game:this});
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