package coldboot.states;
import coldboot.UpdateInfo;
import coldboot.IState;
import coldboot.Game;
import coldboot.Entity;
import coldboot.IGameState;
import coldboot.RenderInfo;
import coldboot.rendering.opengl.Shader;
import coldboot.rendering.opengl.Cube;
import glm.GLM;
import glm.*;
import lime.utils.Float32Array;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GL;
import coldboot.rendering.opengl.Symbology;
using coldboot.rendering.opengl.GLMExt;

/**
 * ...
 * @author Andreas Kennedy
 */
class RenderTestState implements IGameState {

  var testShader:Shader;
  var cube:Cube;

  var uModel:GLUniformLocation;
  var uView:GLUniformLocation;
  var uProjection:GLUniformLocation;
  var uNormal:GLUniformLocation;
  var aPosition:Int;
  var aNormal:Int;
  public function new() {
    testShader = new Shader([Vertex("assets/basic.vert"), Fragment("assets/basic.frag")], "Basic");

    uModel = testShader.getUniform("uModel");
    uView = testShader.getUniform("uView");
    uProjection = testShader.getUniform("uProjection");
    uNormal = testShader.getUniform("uNormal");
    aPosition = testShader.getAttribute("aPosition");
    aNormal = testShader.getAttribute("aNormal");

    cube = new Cube();
    
  }
  
  
  /* INTERFACE coldboot.IGameState */
  
  public function render(info:RenderInfo):Void {
    GL.clearColor(0.2, 0.2, 0.2, 1.0);
    GL.clear(GL.COLOR_BUFFER_BIT|GL.DEPTH_BUFFER_BIT);

		GL.enable(GL.DEPTH_TEST);
		GL.depthFunc(GL.LESS);
    GL.enable(GL.CULL_FACE);
		GL.cullFace(GL.BACK);

    testShader.bind();

		inline function degRad(deg:Float) {
			return deg * 3.14 / 180;
		}

    var tmp = new Mat4();
    var tmpq = new Quat();
    var model = Mat4.identity(new Mat4());
    model *= GLM.scale(new Vec3(80,80,80), tmp);
    model *= GLM.rotate(Quat.fromEuler(degRad(45), 0, 0, tmpq), tmp);
    model *= GLM.rotate(Quat.fromEuler(0, degRad(45 - info.time * 30), 0, tmpq), tmp);

    var view = Mat4.identity(new Mat4());
    view *= GLM.translate(new Vec3(0,0, -100), tmp);
    var projection = GLM.orthographic(-400, 400, 300, -300, 0.1, 1000, new Mat4());

		var normalMatrix = (view * model).toMat3();
		Mat3.invert(normalMatrix, normalMatrix);
		Mat3.transpose(normalMatrix, normalMatrix);

    GL.uniformMatrix3fv(uNormal, 1, true, new Float32Array(normalMatrix.toFloatArray()));
    GL.uniformMatrix4fv(uModel, 1, false, new Float32Array(model.toFloatArray()));
    GL.uniformMatrix4fv(uView, 1, false, new Float32Array(view.toFloatArray()));
    GL.uniformMatrix4fv(uProjection, 1, false, new Float32Array(projection.toFloatArray()));

    GL.bindBuffer(GL.ARRAY_BUFFER, cube.vbo);
    GL.vertexAttribPointer(aPosition, 4, GL.FLOAT, false, 0, 0);
    GL.enableVertexAttribArray(aPosition);

    GL.bindBuffer(GL.ARRAY_BUFFER, cube.nbo);
    GL.enableVertexAttribArray(aNormal);
    GL.vertexAttribPointer(aNormal, 4, GL.FLOAT, true, 0, 0);

    GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, cube.ibo);
    GL.drawElements(GL.TRIANGLES, Cube.indices.length, GL.UNSIGNED_SHORT, 0);

    testShader.release();

    Symbology.endFrame(info.game.viewportSize.width, info.game.viewportSize.height);

  }
  
  public function getRootEntity():Entity {
    return null;
  }
  
  public function enter(g:Game, ?info:Dynamic):Void {
    
  }
  
  public function update(info:UpdateInfo):IState {
    Symbology.beginFrame();

    Symbology.point(info.game.viewportSize.width/2, info.game.viewportSize.height/2, 8);
    Symbology.triangle(info.game.viewportSize.width/2, info.game.viewportSize.height/2, 100, 100, 0, true, 0.25);
    Symbology.square(info.game.viewportSize.width/2, info.game.viewportSize.height/2, 200, 200, 0);
    Symbology.circle(info.game.viewportSize.width/2, info.game.viewportSize.height/2, 300);
    return this;
  }
  
  public function exit(g:Game):Void {
    
  }

}