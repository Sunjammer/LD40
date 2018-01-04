package coldboot.rendering.opengl.posteffects;
import coldboot.rendering.opengl.*;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.*;

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
        threshTarget = TextureUtils.makeTarget(config.width, config.height);
        compositeTarget = TextureUtils.makeTarget(config.width, config.height);

        for(t in pingPongTargets)
            deleteTarget(t);
        
        for(i in 0...2){
            pingPongTargets.push(TextureUtils.makeTarget(config.width, config.height));
        }
    }

    function deleteTarget(t:Target){
        if(t==null) return;
        GL.deleteFramebuffer(t.fbo);
        GL.deleteTexture(t.tex);
    }

    override public function render(){
        // Thresh
        threshShader.bind();
        GL.bindFramebuffer(GL.FRAMEBUFFER, threshTarget.fbo);

        GL.activeTexture(GL.TEXTURE0);
        GL.bindTexture(GL.TEXTURE_2D, texture);
        Quad.draw();

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
            Quad.draw();
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

        Quad.draw();
		compositeShader.release();

		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION) {
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
		GL.disableVertexAttribArray(vertexAttribute);
    }

}