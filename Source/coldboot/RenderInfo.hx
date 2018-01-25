package coldboot;

import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GL;

typedef Viewport = {
    width:Int,
    height:Int,
    aspect:Float
}

@:build(smashgl.GLDebug.build())
class Session{
    public var time:Float;
    var fboStack:Array<GLFramebuffer>;
    public function new(){
        time = 0.0;
        reset();
    }
    public function reset(){
        fboStack = [];
    }

    @gldebug
    public function pushFramebuffer(fbo:GLFramebuffer){
        fboStack.push(GL.getParameter(GL.FRAMEBUFFER_BINDING));
        GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
    }

    @gldebug
    public function popFramebuffer(){
        if(fboStack.length==0)
            return;
        GL.bindFramebuffer(GL.FRAMEBUFFER, fboStack.pop());
    }

    public function setRenderBuffer(fbo:GLFramebuffer){
        fboStack = []; //EEK
        GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
    }
}

class RenderInfo{
    public var session:Session;
    public var game:Game;
    public var viewport:Viewport;
    
    public function new(){
        session = new Session();
    }
}