package coldBoot;
import coldBoot.IGameState;
import coldBoot.states.GamePlayState;
import coldBoot.states.RenderTestState;
import fsignal.Signal2;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLView;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import AudioJank.AudioJank;
import AudioJank.SampleId;

#if ogl
	import coldBoot.rendering.SceneRenderBase;
  import coldBoot.rendering.ScreenNoisePostEffect;
#end
  

class Game extends Sprite
{
	var currentState: IGameState;
	public var stateSpriteContainer:Sprite;
	public var debugContainer:Sprite;
  var glView:OpenGLView;
  var backgroundShape:Shape;

	#if ogl
	var sceneRenderer:SceneRenderBase;
	#end
  
  public var viewportSize:{width:Int, height:Int, aspect:Float};
  public var viewportChanged:Signal2<Int,Int>;
  var globalTime:Float;
  
	public function new(config: {width:Int, height:Int})
	{
		super();

                AudioJank.createContext();
                AudioJank.playSampleInSpace(SampleId.EnemyDialogueHigh3, 0.0, 0.0);
    
    glView = new OpenGLView();
    backgroundShape = new Shape();
    stateSpriteContainer = new Sprite();
    debugContainer = new Sprite();

    viewportChanged = new Signal2<Int,Int>();
    
    addChild(glView);
		addChild(stateSpriteContainer);
		addChild(debugContainer); 
		#if ogl
    viewportSize = {width:0, height:0, aspect:1};
		addChild(sceneRenderer = new SceneRenderBase(config));
		sceneRenderer.setPostEffects(
			[
				//new ScreenNoisePostEffect("assets/crt.frag")
			]
		);
		#end
		setState(new RenderTestState());
	}

	public function resize(dims: {width:Int, height:Int})
	{
    viewportSize.width = dims.width;
    viewportSize.height = dims.height;
    viewportSize.aspect = dims.width / dims.height;
		#if ogl
		sceneRenderer.setWindowSize(viewportSize);
		#end
    
    viewportChanged.dispatch(viewportSize.width, viewportSize.height);
	}

	public function getCurrentState():IGameState
	{
		return currentState;
	}

	public function update(dt:Float)
	{
    globalTime += dt;
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
		GL.viewport (Std.int (0), Std.int (0), Std.int (viewportSize.width), Std.int (viewportSize.height));
		sceneRenderer.preRender();
		currentState.render({game:this, time:globalTime});
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
    globalTime = 0;
		if (currentState != null)
		{
			currentState.exit(this);
		}
		currentState = s;
		currentState.enter(this);
		return currentState;
	}
}