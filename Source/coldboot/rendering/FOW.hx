package coldboot.rendering;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.*;
import smashgl.*;
import openfl.Assets;
typedef PaintCommand = {x:Float, y:Float, radius:Float, value:Float}

 @:build(smashgl.GLDebug.build())
class FOW{
    var target:Target;
    var cmds:Array<PaintCommand>;
    var shader:Shader;
    var uTime:GLUniformLocation;
    var uResolution:GLUniformLocation;
    static inline var w:Int = 320;
    static inline var h:Int = 320;
    public function new(){
        reset();
    }
    public function reset(){
        cmds = [];

        target = TextureUtils.makeTarget(w, h);

        shader = new Shader(
            [
                Vertex(Assets.getText("assets/shaders/fullscreenquad.vert")), 
                Fragment(Assets.getText("assets/shaders/fow.frag"))
            ], "FOW");
        
        uResolution = shader.getUniform("uResolution");
        uTime = shader.getUniform("uTime");
    }

    public function getTexture():GLTexture{
        return target.tex;
    }

    @gldebug
    public function render(info:RenderInfo){
        if(cmds.length==0) return;
        info.session.pushFramebuffer(target.fbo);
        Quad.bind();
        shader.bind();

        GL.enableVertexAttribArray(shader.getAttribute("aVertex"));
        GL.vertexAttribPointer(shader.getAttribute("aVertex"), 4, GL.FLOAT, false, 0, 0);

        GL.uniform1f(uTime, info.session.time);
        GL.uniform2f(uResolution, w, h);
        while(cmds.length>0){
            execute(cmds.pop());
        }
        Quad.release();
        shader.release();
        info.session.popFramebuffer();
    }

    inline function execute(cmd:PaintCommand){

    }

    public function reveal(x:Float, y:Float, radius:Float){
        cmds.push({x:x, y:y, radius:radius, value:-1.0});
    }
    public function hide(x:Float, y:Float, radius:Float){
        cmds.push({x:x, y:y, radius:radius, value:1.0});
    }
}