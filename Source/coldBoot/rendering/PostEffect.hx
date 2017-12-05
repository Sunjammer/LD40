package coldBoot.rendering;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

typedef PostProcessConfig = { width:Int, height:Int }

							typedef Uniform =
{
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

	private var vertexAttrib:Int;
	private var texCoordSlot:Int;
	private var imageUniform:GLUniformLocation;
	private var resolutionUniform:GLUniformLocation;
	private var timeUniform:GLUniformLocation;
	private var uniforms:Map<String, Uniform>;

	var config:PostProcessConfig;
	var fragShaderPath:String;
	public function new(fragmentShader:String)
	{
		fragShaderPath = fragmentShader;
		
		if (shader != null) shader.destroy();
		shader = new Shader([
		{ src: Assets.getText("assets/fullscreenquad.vert"), fragment: false },
		{ src: Assets.getText(fragShaderPath), fragment: true }
		], fragShaderPath );

		uniforms = new Map<String, Uniform>();
		imageUniform = shader.uniform("uImage0");
		timeUniform = shader.uniform("uTime");
		resolutionUniform = shader.uniform("uResolution");
	}

	public function bind(config, ?to:PostEffect)
	{
		this.config = config;
		rebuild();
		this.to = to;
	}

	public function toString():String
	{
		return "[Post effect: " + fragShaderPath+"]";
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

	private function get_to():PostEffect
	{
		return target;
	}

	public function rebuild()
	{
		if (framebuffer != null) GL.deleteFramebuffer(framebuffer);
		framebuffer = GL.createFramebuffer();
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

		if (texture != null) GL.deleteTexture(texture);
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);

		texture = Utils.createTexture(config.width, config.height);
		bindTextureToFramebuffer();
		createRenderbuffer(config.width, config.height);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	private inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);
		renderbuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);

		// Specify renderbuffer as depth attachement
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
	}

	function bindTextureToFramebuffer()
	{
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
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	public function prerender()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTo);

		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		shader.bind();
	}

	public function update(dt:Float)
	{
		time += dt;

		GL.uniform1i(imageUniform, 0);
		GL.uniform1f(timeUniform, time);
		GL.uniform2f(resolutionUniform, config.width, config.height);

		for (u in uniforms)
			GL.uniform1f(u.id, u.value);
	}

	public function render()
	{
		GL.enable(GL.TEXTURE_2D);
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);

		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		GL.useProgram(null);

		// check gl error
		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
		{
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
	}
}