package coldboot.rendering.opengl.posteffects;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.*;

typedef Target = {fbo:GLFramebuffer, tex:GLTexture}

class HDRBloom extends PostEffect{

    var threshShader:Shader;
    var threshTarget:Target;

    var compositeShader:Shader;
    var compositeTarget:Target;

    var uHorizontal:GLUniformLocation;
    var uBloomTexture:GLUniformLocation;
    var pingPongTargets:Array<Target>;
    public function new(){
        super("assets/shaders/GaussianBlur.frag", "Gaussian blur");
        uHorizontal = shader.getUniform("uHorizontal");
        pingPongTargets = []; 

        threshShader = new Shader([
				Vertex("assets/shaders/fullscreenquad.vert"),
				Fragment("assets/shaders/threshold.frag")
			], "Threshold");

        compositeShader = new Shader([
				Vertex("assets/shaders/fullscreenquad.vert"),
				Fragment("assets/shaders/composite.frag")
			], "Composite");

        uBloomTexture = compositeShader.getUniform("uBloomTexture");
    }

    override public function rebuild(config: {width:Int, height:Int}) {
        super.rebuild(config);

        deleteTarget(threshTarget);
        deleteTarget(compositeTarget);
        threshTarget = makeTarget(config);
        compositeTarget = makeTarget(config);

        for(t in pingPongTargets)
            deleteTarget(t);
        
        for(i in 0...2){
            pingPongTargets.push(makeTarget(config));
        }
    }

    function deleteTarget(t:Target){
        if(t==null) return;
        GL.deleteFramebuffer(t.fbo);
        GL.deleteTexture(t.tex);
    }

    function makeTarget(config:{width:Int, height:Int}):Target
    {
        var fbo = GL.createFramebuffer();
        var tex = GL.createTexture();
        GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB16F, config.width, config.height, 0, GL.RGB, GL.UNSIGNED_BYTE, 0);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, tex, 0);
        
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT);
        

		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		switch (status) {
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}

        return { tex:tex, fbo:fbo };
    }

    override public function render(){
        // Thresh
        threshShader.bind();
        GL.bindFramebuffer(GL.FRAMEBUFFER, threshTarget.fbo);

        GL.activeTexture(GL.TEXTURE0);
        GL.bindTexture(GL.TEXTURE_2D, texture);
        drawQuad();

        // Blur
        shader.bind();
        var amount = 15;
        var horizontal = 1;
        var firstIteration = true;
        
        for(i in 0...amount){
            GL.bindFramebuffer(GL.FRAMEBUFFER, pingPongTargets[horizontal].fbo);
            GL.uniform1i(uHorizontal, horizontal);
            GL.activeTexture(GL.TEXTURE0);
            GL.bindTexture(GL.TEXTURE_2D, firstIteration?threshTarget.tex:pingPongTargets[1-horizontal].tex);
            drawQuad();
            horizontal = 1 - horizontal;
            firstIteration = false;
        }

        // Combine
        compositeShader.bind();
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTarget);
        GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);
        GL.activeTexture(GL.TEXTURE1);
		GL.bindTexture(GL.TEXTURE_2D, pingPongTargets[horizontal].tex);
		GL.uniform1i(uBloomTexture, 1);

        drawQuad();
		compositeShader.release();

		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION) {
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
		GL.disableVertexAttribArray(vertexAttribute);
    }

}