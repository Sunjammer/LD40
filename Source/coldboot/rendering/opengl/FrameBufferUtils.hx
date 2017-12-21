package coldboot.rendering.opengl;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLTexture;
class FrameBufferUtils{
	public static inline function createRenderbuffer(width:Int, height:Int):GLRenderbuffer {
		var renderbuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
        return renderbuffer;
	}

    public static inline function bindRenderBufferToFrameBuffer(renderbuffer:GLRenderbuffer, framebuffer:GLFramebuffer){
        
    }

	public static inline function bindTextureToFramebuffer(buffer:GLFramebuffer, texture:GLTexture) {
		// specify texture as color attachment
		GL.bindFramebuffer(GL.FRAMEBUFFER, buffer);
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
}