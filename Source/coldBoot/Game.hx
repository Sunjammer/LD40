package coldBoot;
import coldBoot.IGameState;
import coldBoot.states.GamePlayState;

#if ogl
	import coldBoot.rendering.PostEffect;
	import coldBoot.rendering.SceneRenderBase;
#end
import coldBoot.cpu.Bytecode.Comparison;
import coldBoot.rendering.ScreenNoisePostEffect;
import coldBoot.states.InitialState;
import fsignal.Signal;
import fsignal.Signal1;
import fsignal.Signal2;
import openfl.display.Shape;
import glm.Vec2;
import openfl.display.Sprite;
import tween.Delta;
  

class Game extends Sprite
{
	var currentState: IGameState;
	public var spriteContainer:Sprite;
	public var debugContainer:Sprite;
  var backgroundShape:Shape;

	#if ogl
	var sceneRenderer:SceneRenderBase;
	#end
  
  public var viewportSize:{width:Int, height:Int};
  public var viewportChanged:Signal2<Int,Int>;
  
	public function new(config: {width:Int, height:Int})
	{
		super();

    viewportChanged = new Signal2<Int,Int>();
    addChild(backgroundShape = new Shape());
		addChild(spriteContainer = new Sprite());
		addChild(debugContainer = new Sprite()); 
		#if ogl
    viewportSize = {width:0, height:0};
		addChild(sceneRenderer = new SceneRenderBase(config));
		sceneRenderer.setPostEffects(
			[
				new ScreenNoisePostEffect("assets/crt.frag")
			]
		);
		#end
		setState(new InitialState());
	}

	public function resize(dims: {width:Int, height:Int})
	{
    viewportSize.width = dims.width;
    viewportSize.height = dims.height;
		#if ogl
		sceneRenderer.setWindowSize(viewportSize);
		#end
    backgroundShape.graphics.clear();
    backgroundShape.graphics.beginFill();
    backgroundShape.graphics.drawRect(0, 0, viewportSize.width, viewportSize.height);
    viewportChanged.dispatch(viewportSize.width, viewportSize.height);
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