package coldboot;
import coldboot.IGameState;
import coldboot.ai.PathFinding;
import coldboot.rendering.opengl.Cube;
import coldboot.rendering.opengl.posteffects.*;
import coldboot.states.*;
import fsignal.Signal2;
import glm.Vec2;
import lime.graphics.opengl.GL;
import openfl.Assets;
import openfl.display.OpenGLView;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;

class Input{
	public var mouse:Vec2;
	public function new(){
		mouse = new Vec2();
	}
}

 @:build(coldboot.rendering.opengl.GLDebug.build())
class Game extends Sprite
{
	var currentState: IGameState;
	public var stateSpriteContainer:Sprite;
	public var debugContainer:Sprite;
	var glView:OpenGLView;
	var backgroundShape:Shape;

	var sceneRenderer:PostProcessing;

	public var viewportChanged:Signal2<Int,Int>;
  	public var audio:Audio;
	public var input:Input;
	public var renderInfo:RenderInfo;
	var globalTime:Float;

	public function new(config: {width:Int, height:Int})
	{
		super();
		input = new Input();
		
		trace("Initializing game");
		viewportChanged = new Signal2<Int,Int>();
		renderInfo = new RenderInfo();
		renderInfo.game = this;
		renderInfo.viewport = {width:800, height:600, aspect:1};
    
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
		sceneRenderer.setWindowSize(renderInfo.viewport);
		sceneRenderer.setEffects(
			[
				new PostEffect("assets/shaders/dither.frag", "Dithering"),
				new HDRBloom(),
				new PostEffect("assets/shaders/mpeg.frag", "Mpeg artifacts", [
					"assets/textures/white_noise.png"
				],
				["uAmount"=>Float2(1.0, 0.6)]),
				new PostEffect("assets/shaders/crt.frag", "CRT",
					[
						"assets/textures/screen_noise.jpg", 
						"assets/textures/dirt.jpg", 
						"assets/textures/distpattern.jpg"
					]),
				new PostEffect("assets/shaders/tonemapper.frag", "Tone mapping")
			]
		);
		
		setState(new InitialState(), [
			"assets/textures/c1.jpg",
			"assets/textures/c2.jpg",
			"assets/textures/c3.jpg",
			"assets/textures/c4.jpg",
			"assets/textures/c5.jpg",
			"assets/textures/c6.jpg"
		]);
	}

	public function resize(dims: {width:Int, height:Int})
	{
		renderInfo.viewport.width = dims.width;
		renderInfo.viewport.height = dims.height;
		renderInfo.viewport.aspect = dims.width / dims.height;
		sceneRenderer.setWindowSize(renderInfo.viewport);
		viewportChanged.dispatch(renderInfo.viewport.width, renderInfo.viewport.height);
	}

	public function getCurrentState():IGameState
	{
		return currentState;
	}

	public function update(dt:Float)
	{
		input.mouse = new Vec2(stage.mouseX, stage.mouseY);
		PathFinding.update();
		globalTime += dt;
		var info = {game:this, deltaTime:dt, time:globalTime};
		Delta.step(info.deltaTime);
		if (currentState != null)
			currentState.update(info);
	}

	#if !display
	override function __renderGL(renderSession):Void
	{
		GL.viewport (0, 0, renderInfo.viewport.width, renderInfo.viewport.height);
		GL.clearColor(0,0,0,1);
		GL.clear(GL.COLOR_BUFFER_BIT|GL.DEPTH_BUFFER_BIT);
		renderInfo.session.reset();
		renderInfo.session.time = globalTime;
		sceneRenderer.beginFrame(renderInfo);
		currentState.render(renderInfo);
		super.__renderGL(renderSession);
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