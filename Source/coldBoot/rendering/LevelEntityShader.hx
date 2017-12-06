package coldBoot.rendering;
import coldBoot.rendering.Shader;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class LevelEntityShader extends Shader
{
	public var dataTextureUniform:GLUniformLocation;
	public var screenNoiseUniform:GLUniformLocation;
	public var dataTexture:GLTexture;
	public var screenNoiseTex:GLTexture;

	public function new()
	{
		super([
			{src:Assets.getText("assets/level_entity.vert"), type:GL.VERTEX_SHADER},
			{src:Assets.getText("assets/level_entity.frag"), type:GL.FRAGMENT_SHADER}
		]);

		dataTextureUniform = uniform("uDataTexture");
		dataTexture = Utils.createTextureFromBitmap("assets/testpattern.jpg", true);
		screenNoiseUniform = uniform("uNoiseTexture");
		screenNoiseTex = Utils.createTextureFromBitmap("assets/perlin_noise.png", true);
	}
	override public function bind()
	{
		super.bind();
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, screenNoiseTex);
		GL.uniform1i(screenNoiseUniform, 0);
		GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, dataTexture);
		GL.uniform1i(dataTextureUniform, 1);
	}
}