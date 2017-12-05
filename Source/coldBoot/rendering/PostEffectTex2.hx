package coldBoot.rendering;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;

/**
 * ...
 * @author Andreas Rønning
 */
class PostEffectTex2 extends PostEffectTex1
{
	var tex2:GLTexture;
	var image2Uniform:GLUniformLocation;

	public function new(frag:String, texFilePath1:String, texFilePath2:String) 
	{
		super(frag, texFilePath1);
		image2Uniform = shader.uniform("uImage2");
		tex2 = Utils.createTextureFromBitmap(texFilePath2);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		GL.activeTexture(GL.TEXTURE2);
		GL.bindTexture(GL.TEXTURE_2D, tex2);
		GL.uniform1i(image2Uniform, 2);
	}
	
}