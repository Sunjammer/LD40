package coldBoot.rendering;
import coldBoot.Game;
import coldBoot.rendering.PostEffect;
import lime.app.Config.WindowConfig;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Andreas Kennedy
 */
class SceneRenderBase extends OpenGLView {
  var effects:Array<PostEffect>;
  var prevDelta:Float;
  var config:WindowConfig;

  public function new(config:WindowConfig) {
    super();
    this.render = renderView;
    this.config = config; 
  }
  
  public function setPostEffects(inEffects:Array<PostEffect>){
    effects = inEffects;
    
    switch(effects.length){
      case 0:
        return;
      case 1:
       effects[0].bind(config);
      default:
        for (i in 0...effects.length){
          var p = effects[i];
          if (i == effects.length - 1){
            p.bind(config);
          }
          else{
            p.bind(config, effects[i + 1]);
          }
        }
    }
    
  }
  
  public function setWindowSize(config:WindowConfig){
    this.config = config;
    for (p in effects){
      p.bind(config);
    }
  }
  
  public function preRender(){
    if (effects.length == 0) return;
    effects[0].capture();
  }
  
  private function renderView (rect:Rectangle):Void {
    if (effects.length == 0) return;
    for (p in effects){
      p.render(prevDelta);
    }
  }
  
  public function update(game:coldBoot.Game, dt:Float) {
    prevDelta = dt;
  }
  
  
  
}