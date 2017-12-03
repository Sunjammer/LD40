package coldBoot.rendering;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

typedef PostProcessConfig = { width:Int, height:Int }

typedef Uniform = {
	var id:GLUniformLocation;
	var value:Float;
};

class PostEffect
{
	private var framebuffer:GLFramebuffer;
	private var renderbuffer:GLRenderbuffer;
	private var texture:GLTexture;

	private var shader:Shader;
	private var buffer:GLBuffer;
	private var renderTo:GLFramebuffer;
	private var defaultFramebuffer:GLFramebuffer = null;

	private var time:Float = 0;

	private var vertexSlot:Int;
	private var texCoordSlot:Int;
	private var imageUniform:GLUniformLocation;
	private var screenNoiseUniform:GLUniformLocation;
	private var resolutionUniform:GLUniformLocation;
	private var timeUniform:GLUniformLocation;
	private var uniforms:Map<String, Uniform>;

	private var screenNoiseTex:GLTexture;

	private static inline var fullscreenQuadFrag:String = "
	#version 120
	#extension GL_EXT_gpu_shader4 : require
	varying vec2 vTexCoord;
	void main()
	{
		vec4 quadVertices[4];
		quadVertices[0] = vec4( -1.0, -1.0, 0.0, 0.0); 
		quadVertices[1] = vec4(1.0, -1.0, 1.0, 0.0); 
		quadVertices[2] = vec4( -1.0, 1.0, 0.0, 1.0); 
		quadVertices[3] = vec4(1.0, 1.0, 1.0, 1.0);

		vTexCoord = quadVertices[gl_VertexID].zw;
		gl_Position = vec4(quadVertices[gl_VertexID].xy, 0.0, 1.0);
	}
	";


	var config:PostProcessConfig;  
	var shaderName:String;
	public function new(fragmentShader:String){
		shaderName = fragmentShader;
		framebuffer = GL.createFramebuffer();
	
		shader = new Shader([
			{ src: fullscreenQuadFrag, fragment: false },
			{ src: Assets.getText(fragmentShader), fragment: true }
		]);

		uniforms = new Map<String, Uniform>();
		imageUniform = shader.uniform("uImage0");
		timeUniform = shader.uniform("uTime");
		resolutionUniform = shader.uniform("uResolution");
		screenNoiseUniform = shader.uniform("uImage1");

		var bitmap = Assets.getBitmapData("assets/screen_noise.jpg");
		screenNoiseTex = createTexture(bitmap.width, bitmap.height, true);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bitmap.width, bitmap.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bitmap.image.data);

		texCoordSlot = shader.attribute("aTexCoord");
	}

	public function bind(config, ?to:PostEffect)
	{
		this.config = config;
		rebuild();
		this.to = to;
	}

	public function toString():String{
		return "[Post effect: " + shaderName+"]";
	}

	public function setUniform(uniform:String, value:Float):Void
	{
		if (uniforms.exists(uniform))
		{
			var uniform = uniforms.get(uniform);
			uniform.value = value;
		}
		else
		{
			var id = shader.uniform(uniform);
			#if js
			if (id != null) uniforms.set(uniform, {id: id, value: value});
			#else
			uniforms.set(uniform, {id: id, value: value});
			#end
		}
	}

	var target:PostEffect;
	public var to(get, set):PostEffect;
	private function set_to(value:PostEffect):PostEffect
	{
		renderTo = (value == null ? defaultFramebuffer : value.framebuffer);
		return target = value;
	}

	private function get_to():PostEffect{
		return target;
	}

	public function rebuild()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

		if (texture != null) GL.deleteTexture(texture);
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);

		texture = createTexture(config.width, config.height);
		bindTextureToFramebuffer();
		createRenderbuffer(config.width, config.height);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	private inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		renderbuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);

		// Specify renderbuffer as depth attachement
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
	}

	private inline function createTexture(width:Int, height:Int, repeat:Bool = false)
	{
		var tex = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB,  width, height,  0,  GL.RGB, GL.UNSIGNED_BYTE, 0);

		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		return tex;
	}

	function bindTextureToFramebuffer() {
		// specify texture as color attachment
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		switch (status)
		{
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}
	}

	public function capture()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.viewport(0, 0, config.width, config.height);
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}

	/**
	 * Renders to a framebuffer or the screen every frame
	 */
  
	public function render(dt:Float)
	{
		time += dt;
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTo);

		GL.clearColor(0,0,0,1);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		shader.bind();

		GL.enableVertexAttribArray(vertexSlot);
		GL.enableVertexAttribArray(texCoordSlot);

		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);

		GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, screenNoiseTex);

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.vertexAttribPointer(vertexSlot, 2, GL.FLOAT, false, 16, 0);
		GL.vertexAttribPointer(texCoordSlot, 2, GL.FLOAT, false, 16, 8);

	
		GL.uniform1i(imageUniform, 0);
		GL.uniform1f(timeUniform, time);
		GL.uniform2f(resolutionUniform, config.width, config.height);
		GL.uniform1i(screenNoiseUniform, 1);

		for (u in uniforms) 
			GL.uniform1f(u.id, u.value);
	
		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);

		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.disable(GL.TEXTURE_2D);
		GL.bindTexture(GL.TEXTURE_2D, null);

		GL.disableVertexAttribArray(vertexSlot);
		GL.disableVertexAttribArray(texCoordSlot);

		GL.useProgram(null);

		// check gl error
		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
		{
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
	}
}