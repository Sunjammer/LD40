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
 @:build(coldboot.rendering.opengl.GLDebug.build())
class LevelShader extends Shader
{
	var textureUniform:GLUniformLocation;
	var uFowTex:GLUniformLocation;
	var texture:GLTexture;
	var fowTexture:GLTexture;

	public function new(levelColorTexturePath:String, fowTexture:GLTexture)
	{
		super([
			Vertex("assets/shaders/level_entity.vert"),
			Fragment("assets/shaders/level_entity.frag")
		], "Level");

		textureUniform = getUniform("uColorTex");
		uFowTex = getUniform("uFowTex");
		texture = TextureUtils.createTextureFromBitmap(levelColorTexturePath, true);
		this.fowTexture = fowTexture;

	}

	override public function bind(){
		super.bind();

		GL.uniform1i(textureUniform, 0);
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);

		GL.uniform1i(uFowTex, 1);
		GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, fowTexture);
	}
}