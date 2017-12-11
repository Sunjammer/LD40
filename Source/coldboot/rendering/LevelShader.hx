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
	var texture:GLTexture;

	public function new(levelColorTexturePath:String)
	{
		super([
			Vertex(Assets.getText("assets/level_entity.vert")),
			Fragment(Assets.getText("assets/level_entity.frag"))
		], "Level");

		textureUniform = getUniform("uColorTex");
		texture = TextureUtils.createTextureFromBitmap(levelColorTexturePath, true);

	}

	override public function bind(){
		super.bind();

		GL.uniform1i(textureUniform, 0);
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);
	}
}