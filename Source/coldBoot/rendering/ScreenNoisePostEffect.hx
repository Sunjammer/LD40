package coldBoot.rendering;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class ScreenNoisePostEffect extends PostEffect {


	private var screenNoiseTex:GLTexture;
	private var screenNoiseUniform:GLUniformLocation;
  public function new(frag:String) {
    super(frag);
		screenNoiseUniform = shader.uniform("uImage1");
		screenNoiseTex = Utils.createTextureFromBitmap("assets/screen_noise.jpg");
  }
  
  override public function update(dt:Float) {
    super.update(dt);
		GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, screenNoiseTex);
		GL.uniform1i(screenNoiseUniform, 1);
  }
  
}