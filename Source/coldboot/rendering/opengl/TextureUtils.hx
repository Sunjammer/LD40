package coldboot.rendering.opengl;

import lime.graphics.opengl.*;
import openfl.Assets;

class TextureUtils{

	public static function makeTarget(width:Int, height:Int, isFloat:Bool = true):Target
    {
        var fbo = GL.createFramebuffer();
        var tex = GL.createTexture();
        GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB, GL.UNSIGNED_BYTE, 0);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, tex, 0);
        
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT);
        

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

        return { tex:tex, fbo:fbo };
    }

	static public inline function createRenderTargetTexture(width:Int, height:Int){
        var tex = GL.createTexture();
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB, GL.UNSIGNED_BYTE, 0);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.bindTexture(GL.TEXTURE_2D, 0);
		return tex;
	}

	static public inline function createTexture(width:Int, height:Int, repeat:Bool = false, format:Int = GL.RGBA, filter:Int = GL.LINEAR)
	{
		var tex = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2D(GL.TEXTURE_2D, 0, format, width, height,  0,  GL.RGB, GL.UNSIGNED_BYTE, 0);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filter);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filter);
		GL.bindTexture(GL.TEXTURE_2D, null);
		return tex;
	}
  
 	static public inline function createTextureFromBitmap(path:String, repeat:Bool = false){
		var bitmap = Assets.getBitmapData(path);
		var tex = createTexture(bitmap.width, bitmap.height, repeat, GL.RGBA);
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bitmap.width, bitmap.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bitmap.image.data);
		GL.bindTexture(GL.TEXTURE_2D, null);
		return tex;
	}
  
}