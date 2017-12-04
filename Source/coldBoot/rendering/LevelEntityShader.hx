package coldBoot.rendering;
import coldBoot.rendering.Shader.ShaderSource;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class LevelEntityShader extends Shader{
  public var screenNoiseUniform:GLUniformLocation;
  public var screenNoiseTex:GLTexture;

  public function new() {
    super([
      {src:Assets.getText("assets/level_entity.vert"), fragment:false},
      {src:Assets.getText("assets/level_entity.frag"), fragment:true}]
      );
      
      
		screenNoiseUniform = uniform("uNoiseTexture");
		screenNoiseTex = Utils.createTextureFromBitmap("assets/perlin_noise.png", true);
  }
  override public function bind() {
    super.bind();
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, screenNoiseTex);
		GL.uniform1i(screenNoiseUniform, 1);
  }
}