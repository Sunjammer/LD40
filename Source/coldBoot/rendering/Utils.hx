package coldBoot.rendering;
import lime.graphics.opengl.GL;
import openfl.utils.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class Utils {

	static public inline function createTexture(width:Int, height:Int, repeat:Bool = false)
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
  
  static public inline function createTextureFromBitmap(path:String, repeat:Bool = false){
		var bitmap = Assets.getBitmapData(path);
		var tex = Utils.createTexture(bitmap.width, bitmap.height, repeat);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bitmap.width, bitmap.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bitmap.image.data);
    return tex;
    
  }
  
}