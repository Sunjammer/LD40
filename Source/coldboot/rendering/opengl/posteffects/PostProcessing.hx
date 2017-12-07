package coldboot.rendering.opengl.posteffects;

import lime.graphics.opengl.*;
import lime.utils.Float32Array;
import openfl.display.OpenGLView;
import coldboot.rendering.opengl.posteffects.PostEffect;

class PostProcessing extends OpenGLView{
	var effects:Array<coldboot.rendering.opengl.posteffects.PostEffect>;
	var config:{width:Int, height:Int};
	
	var vbo:GLBuffer;
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
		buildQuad();
		  
        for(e in effects)
            e.rebuild(config);

		chainEffects();
    }
	
	function buildQuad() {
		if (vbo != null) GL.deleteBuffer(vbo);
		  vbo = GL.createBuffer();
		  
		var vertices:Array<Float> = [
		  -1, -1, 0, 0,
		  1, -1, 1, 0,
		  1, 1, 1, 1,
		  -1, 1, 0, 1
		];
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
		GL.bufferData(GL.ARRAY_BUFFER, 4 * Float32Array.BYTES_PER_ELEMENT * vertices.length, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
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
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
		for (p in effects)
		{
			p.prepare(time, config);
			p.render();
		}
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function beginFrame(inTime:Float){
		if (effects.length == 0) return;
		time = inTime;
		effects[0].beginCapture(config);
	}
}