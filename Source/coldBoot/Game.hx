package coldboot;
import coldboot.IGameState;
import coldboot.rendering.opengl.posteffects.*;
import coldboot.states.GamePlayState;
import coldboot.states.InitialState;
import fsignal.Signal2;
import lime.graphics.opengl.GL;
import openfl.Assets;
import openfl.display.OpenGLView;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;

class Game extends Sprite
{
	var currentState: IGameState;
	public var stateSpriteContainer:Sprite;
	public var debugContainer:Sprite;
	var glView:OpenGLView;
	var backgroundShape:Shape;

	#if ogl
	var sceneRenderer:PostProcessing;
	#end

	public var viewportSize: {width:Int, height:Int, aspect:Float};
	public var viewportChanged:Signal2<Int,Int>;
	var globalTime:Float;
  public var audio:Audio;

	public function new(config: {width:Int, height:Int})
	{
		super();
		
		trace("Initializing game");
		viewportChanged = new Signal2<Int,Int>();
		viewportSize = {width:800, height:600, aspect:1};
    
    trace("Initializing audio");
    audio = Audio.getInstance();
    audio.init();
		
		trace("Initializing rendering");
		
		backgroundShape = new Shape();
		stateSpriteContainer = new Sprite();
		debugContainer = new Sprite();
		
		addChild(stateSpriteContainer);
		addChild(debugContainer);
		
		#if ogl
		
		addChild(sceneRenderer = new PostProcessing());
		sceneRenderer.setWindowSize({width:800, height:600});
		sceneRenderer.setEffects(
			[
				new PostEffect(Assets.getText("assets/crt.frag"), "CRT", ["assets/screen_noise.jpg", "assets/dirt.jpg"])
			]
		);
		#end
		
		trace("Starting");
		
		setState(new InitialState(), [
			"assets/c1.jpg",
			"assets/c2.jpg",
			"assets/c3.jpg",
			"assets/c4.jpg",
			"assets/c5.jpg",
			"assets/c6.jpg"
		]);
	}

	public function resize(dims: {width:Int, height:Int})
	{
		viewportSize.width = dims.width;
		viewportSize.height = dims.height;
		viewportSize.aspect = dims.width / dims.height;
		sceneRenderer.setWindowSize(viewportSize);
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
		if (currentState != null)
			currentState.update(info);
	}

	#if (!display && ogl)
	override function __renderGL(renderSession):Void
	{
		GL.viewport (Std.int (0), Std.int (0), Std.int (viewportSize.width), Std.int (viewportSize.height));
		sceneRenderer.beginFrame(globalTime);
		currentState.render({game:this, time:globalTime});
		super.__renderGL(renderSession);
	}
	#end

	#if !ogl
	public function render(dt:Float)
	{
		currentState.render({game:this, time:globalTime});
	}
	#end

	public function setState(s:IGameState, ?args:Dynamic): IGameState
	{
		globalTime = 0;
		if (currentState != null)
		{
			currentState.exit(this);
		}
		currentState = s;
		currentState.enter(this, args);
		return currentState;
	}
  
  public function onExit() {
    audio.exec(ShutDown);
  }
}