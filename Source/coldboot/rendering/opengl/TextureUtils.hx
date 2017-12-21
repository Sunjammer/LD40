package coldboot.rendering.opengl;

import lime.graphics.opengl.*;
import openfl.Assets;

class TextureUtils{

	static public inline function createTexture(width:Int, height:Int, repeat:Bool = false, format:Int = GL.RGBA, filter:Int = GL.LINEAR)
	{
		var tex = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2D(GL.TEXTURE_2D, 0, format,  width, height,  0,  format, GL.UNSIGNED_BYTE, 0);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , filter);
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