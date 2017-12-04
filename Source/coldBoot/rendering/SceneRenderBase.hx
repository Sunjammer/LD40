package coldBoot.rendering;
import coldBoot.Game;
import coldBoot.rendering.PostEffect;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Andreas Kennedy
 */
class SceneRenderBase extends OpenGLView
{
	var effects:Array<PostEffect>;
	var prevDelta:Float;
	var config: {width:Int, height:Int};

	public function new(config: {width:Int, height:Int})
	{
		super();
		this.render = renderView;
		this.config = config;
	}

	public function setPostEffects(inEffects:Array<PostEffect>)
	{
		effects = inEffects;

		switch (effects.length)
		{
			case 0:
				return;
			case 1:
				effects[0].bind(config);
			default:
				for (i in 0...effects.length)
				{
					var p = effects[i];
					if (i == effects.length - 1)
					{
						p.bind(config);
					}
					else
					{
						p.bind(config, effects[i + 1]);
					}
				}
		}

	}

	public function setWindowSize(config: {width:Int, height:Int})
	{
		this.config = config;
		for (p in effects)
		{
			p.bind(config);
		}
	}

	public function preRender()
	{
		if (effects.length == 0) return;
		effects[0].capture();
	}

	private function renderView (rect:Rectangle):Void
	{
		if (effects.length == 0) return;
		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		for (p in effects)
		{
			p.prerender();
			p.update(prevDelta);
			p.render();
		}
	}

	public function update(game:coldBoot.Game, dt:Float)
	{
		prevDelta = dt;
	}

}