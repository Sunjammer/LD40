package coldboot;
import coldboot.IGameState;
import coldboot.rendering.opengl.Cube;
import coldboot.rendering.opengl.posteffects.*;
import coldboot.states.*;
import fsignal.Signal2;
import lime.graphics.opengl.GL;
import openfl.Assets;
import openfl.display.OpenGLView;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;

 @:build(coldboot.rendering.opengl.GLDebug.build())
class Game extends Sprite
{
	var currentState: IGameState;
	public var stateSpriteContainer:Sprite;
	public var debugContainer:Sprite;
	var glView:OpenGLView;
	var backgroundShape:Shape;

	var sceneRenderer:PostProcessing;

	public var viewportSize: {width:Int, height:Int, aspect:Float};
	public var viewportChanged:Signal2<Int,Int>;
  	public var audio:Audio;
	var globalTime:Float;

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
		
		addChild(sceneRenderer = new PostProcessing());
		sceneRenderer.setWindowSize({width:800, height:600});
		sceneRenderer.setEffects(
			[
				new PostEffect("assets/dither.frag", "Dithering"),
				new PostEffect("assets/crt.frag", "CRT",
					[
						"assets/screen_noise.jpg", 
						"assets/dirt.jpg", 
						"assets/distpattern.jpg"
					])
			]
		);
		
		trace("Starting");
		
		/*setState(new InitialState(), [
			"assets/c1.jpg",
			"assets/c2.jpg",
			"assets/c3.jpg",
			"assets/c4.jpg",
			"assets/c5.jpg",
			"assets/c6.jpg"
		]);*/

		setState(new RenderTestState());
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
		var info = {game:this, deltaTime:dt, time:globalTime};
		Delta.step(info.deltaTime);
		if (currentState != null)
			currentState.update(info);
	}

	#if (!display && ogl)
	override function __renderGL(renderSession):Void
	{
		GL.viewport (0, 0, viewportSize.width, viewportSize.height);
		GL.clearColor(0,0,0,1);
		GL.clear(GL.COLOR_BUFFER_BIT|GL.DEPTH_BUFFER_BIT);
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