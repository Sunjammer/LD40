package coldboot.rendering.opengl.posteffects;

import coldboot.rendering.opengl.Shader;
import lime.graphics.opengl.*;
import openfl.Assets;
import coldboot.rendering.opengl.TextureUtils;

typedef TextureInput = {uniform:GLUniformLocation, texture:GLTexture, path:String}

class PostEffect {
	var framebuffer:GLFramebuffer;
	var renderbuffer:GLRenderbuffer;
	var texture:GLTexture;

	var shader:Shader;
	var renderTarget:GLFramebuffer;
	var defaultFramebuffer:GLFramebuffer = null;

	var resolutionUniform:GLUniformLocation;
	var vertexAttribute:Int;
	var timeUniform:GLUniformLocation;

	var textureInputs:Array<TextureInput>;
	var imageUniform:lime.graphics.opengl.GLUniformLocation;

	public function new(fragmentShaderSrc:String, name:String = "Effect", ?textures:Array<String>, ?defaultFramebuffer:GLFramebuffer) {
		if (shader != null) shader.destroy();
		shader = new Shader([
								Vertex(Assets.getText("assets/fullscreenquad.vert")),
								Fragment(fragmentShaderSrc)
							], name);

		vertexAttribute = shader.getAttribute("aVertex");
		resolutionUniform = shader.getUniform("uResolution");
		timeUniform = shader.getUniform("uTime");

		imageUniform = shader.getUniform("uImage0");

		if (textures == null) textures = [];
		textureInputs = [for (t in textures) {texture:null, uniform:null, path:t } ];
	}

	public function setRenderTarget(?effect:PostEffect) {
		renderTarget = (effect == null ? defaultFramebuffer : effect.framebuffer);
	}

	public function toString():String {
		return "[Post effect: " + shader.name+"]";
	}

	function buildTextures() {
		var idx = 1;
		for (i in textureInputs) {
			if (i.texture != null)
				GL.deleteTexture(i.texture);
			i.texture = TextureUtils.createTextureFromBitmap(i.path, true);
			i.uniform = shader.getUniform("uImage" + idx);
			idx++;
		}
	}

	public function rebuild(config: {width:Int, height:Int}) {
		destroy();

		buildTextures();

		framebuffer = GL.createFramebuffer();

		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		texture = TextureUtils.createTexture(config.width, config.height);
		bindTextureToFramebuffer(texture);
		createRenderbuffer(config.width, config.height);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	inline function bindTextureToFramebuffer(texture:GLTexture) {
		// specify texture as color attachment
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		switch (status) {
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}
	}

	inline function createRenderbuffer(width:Int, height:Int) {
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);
		renderbuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
	}

	public function prepare(time:Float, config: {width:Int, height:Int}) {
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTarget);
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		GL.enableVertexAttribArray(vertexAttribute);
		GL.vertexAttribPointer(vertexAttribute, 4, GL.FLOAT, false, 0, 0);

		shader.bind();

		GL.enable(GL.TEXTURE_2D);
		GL.uniform1i(imageUniform, 0);
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);

		for (i in 0...textureInputs.length) {
			var idx = i + 1;
			if (textureInputs[i].uniform !=-1) {
				GL.uniform1i(textureInputs[i].uniform, idx);
				GL.activeTexture(GL.TEXTURE0+idx);
				GL.bindTexture(GL.TEXTURE_2D, textureInputs[i].texture);
			}
		}

		GL.uniform2f(resolutionUniform, config.width, config.height);
		GL.uniform1f(timeUniform, time);
	}

	public function render() {
		GL.drawArrays(GL.TRIANGLE_FAN, 0, 4);
		shader.release();

		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION) {
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
		GL.disableVertexAttribArray(vertexAttribute);
	}

	public function destroy() {
		if (framebuffer != null) GL.deleteFramebuffer(framebuffer);
		if (texture != null) GL.deleteTexture(texture);
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);
	}

	public function beginCapture(config: {width:Int, height:Int}) {
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.viewport(0, 0, config.width, config.height);
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}
}