package coldboot.rendering.opengl.posteffects;

import lime.graphics.opengl.*;
import lime.utils.Float32Array;
import openfl.display.OpenGLView;
import coldboot.rendering.opengl.posteffects.PostEffect;
import coldboot.rendering.opengl.Quad;

class PostProcessing extends OpenGLView{
	var effects:Array<coldboot.rendering.opengl.posteffects.PostEffect>;
	var config:{width:Int, height:Int};
	var info:RenderInfo; //Need to hold this to pass into onRender
	var time:Float;
	
	public function new(){
		super();
		render = onRender;
        effects = [];
	}

	public function setWindowSize(config: {width:Int, height:Int})
	{
		this.config = config;
        rebuild(config);
	}

    function rebuild(config: {width:Int, height:Int}){
        for(e in effects)
            e.rebuild(config);

		chainEffects();
    }

	public function setEffects(fx:Array<coldboot.rendering.opengl.posteffects.PostEffect>){
		for(e in effects)
			e.destroy();
		effects = fx;
        rebuild(config);
	}
	
	function chainEffects() 
	{
		for (i in 0...effects.length)
		{
			var p = effects[i];
			if (i == effects.length - 1)
				p.setRenderTarget();
			else
				p.setRenderTarget(effects[i + 1]);
		}
	}

	function onRender(rect){
		if (effects.length == 0) return;
		Quad.bind();
		for (p in effects)
		{
			p.prepare(info, config);
			p.render();
		}
		Quad.release();
	}

	public function beginFrame(info:RenderInfo){
		if (effects.length == 0) return;
		this.info = info;
		effects[0].beginCapture(info, config);
	}
}