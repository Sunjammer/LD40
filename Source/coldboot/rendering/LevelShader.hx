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
	}

	override public function bind()
	{
		super.bind();
	}
}