package coldboot.rendering;
import coldboot.rendering.opengl.Shader;
import coldboot.rendering.opengl.TextureUtils;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class LevelShader extends Shader
{
	public var dataTextureUniform:GLUniformLocation;
	public var screenNoiseUniform:GLUniformLocation;
	public var dataTexture:GLTexture;
	public var screenNoiseTex:GLTexture;

	public function new()
	{
		super([
			Vertex(Assets.getText("assets/level_entity.vert")),
			Fragment(Assets.getText("assets/level_entity.frag"))
		]);

		dataTextureUniform = getUniform("uDataTexture");
		dataTexture = TextureUtils.createTextureFromBitmap("assets/testpattern.jpg", true);
		screenNoiseUniform = getUniform("uNoiseTexture");
		screenNoiseTex = TextureUtils.createTextureFromBitmap("assets/perlin_noise.png", true);
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