package coldBoot.rendering;
import coldBoot.rendering.Shader.ShaderSource;
import openfl.Assets;

/**
 * ...
 * @author Andreas Kennedy
 */
class LevelEntityShader extends Shader{

  public function new() {
    super([
      {src:Assets.getText("assets/level_entity.vert"), fragment:false},
      {src:Assets.getText("assets/level_entity.frag"), fragment:true}]
      );
  }
  
}