package coldBoot;
import coldBoot.IGameState;
import coldBoot.rendering.PostEffect;
import coldBoot.rendering.PostEffectTex2;
import coldBoot.states.CodingTestState;
import coldBoot.states.GamePlayState;
import coldBoot.states.InitialState;
import fsignal.Signal2;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLView;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;

#if AudioJank
import AudioJank.AudioJank;
import AudioJank.SampleId;
#end

#if ogl
	import coldBoot.rendering.SceneRenderBase;
	import coldBoot.rendering.PostEffectTex1;
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

	public var viewportSize: {width:Int, height:Int, aspect:Float};
	public var viewportChanged:Signal2<Int,Int>;
	var globalTime:Float;

	public function new(config: {width:Int, height:Int})
	{
		super();
		
		trace("Initializing game");
		viewportChanged = new Signal2<Int,Int>();
		viewportSize = {width:800, height:600, aspect:1};
		
		trace("Initializing rendering");
		
		backgroundShape = new Shape();
		stateSpriteContainer = new Sprite();
		debugContainer = new Sprite();
		
		addChild(stateSpriteContainer);
		addChild(debugContainer);
		
		#if ogl
		
		addChild(sceneRenderer = new SceneRenderBase(config));
		sceneRenderer.setPostEffects(
			[
				new PostEffectTex2("assets/crt.frag", "assets/screen_noise.jpg", "assets/dirt.jpg"),
				new PostEffect("assets/scanline.frag")
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
		
		trace("Stage resize");
		viewportSize.width = dims.width;
		viewportSize.height = dims.height;
		viewportSize.aspect = dims.width / dims.height;
		
		#if ogl
		sceneRenderer.setWindowSize(viewportSize);
		#end

		viewportChanged.dispatch(viewportSize.width, viewportSize.height);
		trace("Stage resized");
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
}