package coldBoot.rendering;
import coldBoot.rendering.PostEffect;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class PostEffectTex1 extends PostEffect
{

	private var tex1:GLTexture;
	private var image1Uniform:GLUniformLocation;
	public function new(frag:String, texFilePath:String)
	{
		super(frag);
		image1Uniform = shader.uniform("uImage1");
		tex1 = Utils.createTextureFromBitmap(texFilePath);
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, tex1);
		GL.uniform1i(image1Uniform, 1);
	}

}