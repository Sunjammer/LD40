package coldboot.rendering;
import coldboot.rendering.opengl.Cube;
import glm.GLM;
import glm.Mat3;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
using coldboot.rendering.opengl.GLMExt;

/**
 * ...
 * @author Andreas Rønning
 */
class LevelRenderer {

	static var shader:LevelShader;

	var vertices:Array<Float>;
	var indices:Array<Int>;

	var vertVbo:GLBuffer;
	var indexVbo:GLBuffer;
	var positionAttrib:Int;
	var normalAttrib:Int;
	var resolutionUniform:GLUniformLocation;
	var matrixUniform:GLUniformLocation;
	var timeUniform:GLUniformLocation;
	var viewMatrixUniform:GLUniformLocation;
	var lightsUniform:GLUniformLocation;
	var level:Level;
	var modelMatrixUniform:GLUniformLocation;
	var normalMatrixUniform:GLUniformLocation;
	var modelViewMatrixUniform:GLUniformLocation;

	public function new() {
		if (shader==null)
			shader = new LevelShader();

		positionAttrib = shader.getAttribute("aPosition");
		normalAttrib = shader.getAttribute("aNormal");
		
		resolutionUniform = shader.getUniform("uResolution");
		matrixUniform = shader.getUniform("uMvp");
		modelViewMatrixUniform = shader.getUniform("uModelView");
		modelMatrixUniform = shader.getUniform("uModel");
		normalMatrixUniform = shader.getUniform("uNormal");
		viewMatrixUniform = shader.getUniform("uView");
		timeUniform = shader.getUniform("uTime");
		

	}

	public function init(level:Level, map:Array<Int>) {
		this.level = level;
		vertices = [];
		indices = [];

		Cube.build();
		
		var primCount = 0;
		inline function emitCube(coord:Int, x, y, a) {
			var i = 0;
			while (i < Cube.verts.length){
				vertices[coord * 8 + i] = Cube.verts[i] + x * 2 -1;
				vertices[coord * 8 + i + 1] = Cube.verts[i + 1] + y * 2 -1;
				vertices[coord * 8 + i + 2] = Cube.verts[i + 2];
				vertices[coord * 8 + i + 3] = Cube.verts[i + 3];
				
				vertices[coord * 8 + i + 4] = Cube.vertexNormals[i];
				vertices[coord * 8 + i + 5] = Cube.vertexNormals[i + 1];
				vertices[coord * 8 + i + 6] = Cube.vertexNormals[i + 2];
				vertices[coord * 8 + i + 7] = 0.0;
				i += 8;
			}
			i = 0;
			while (i < Cube.indices.length){
				var o = primCount * Cube.indices.length;
				indices[o + i] = Cube.indices[i] + o;
				i++;
			}
			trace(indices);
			primCount++;
		}

		inline function addCubeAt(x:Int, y:Int, type:TileType) {
			var coord = (x + (y * level.width));
			emitCube(coord, x, y, switch (type) {
			case Air:
				0.0;
			case Wall:
				1.0;
			});
		}

		for (y in 0...level.height) {
			for (x in 0...level.width) {
				var coord = x + (y * level.width);
				var tile = map[coord];
				if (tile == 0) {
					addCubeAt(x, y, Air);
				} else {
					addCubeAt(x, y, Wall);
				}
			}
		}
		
		/*indices = Cube.indices;
		vertices = Cube.verts;*/
		
		indexVbo = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexVbo);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, UInt16Array.BYTES_PER_ELEMENT * indices.length, new UInt16Array(indices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		
		vertVbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, vertVbo);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * vertices.length, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function render(info:RenderInfo) {
		GL.clearColor(0, 0, 0, 1);
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);

		GL.enable(GL.DEPTH_TEST);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.depthFunc(GL.LEQUAL);
		
		GL.enable(GL.CULL_FACE);
		GL.cullFace(GL.BACK);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertVbo);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexVbo);
		
		shader.bind();
		
		GL.enableVertexAttribArray(positionAttrib);
		GL.enableVertexAttribArray(normalAttrib);
		
		GL.vertexAttribPointer(positionAttrib, 4, GL.FLOAT, false, 0, 0);
		GL.vertexAttribPointer(normalAttrib, 4, GL.FLOAT, false, 0, 4 * 4);

		function degRad(deg:Float) {
			return deg * 3.14 / 180;
		}

		var model = new Mat4();
		Mat4.identity(model);
		var t = info.time * 0.05;
		model *= GLM.rotate(Quat.fromEuler(degRad( -45), t*15, t*-16, new Quat()), new Mat4());
		//model *= GLM.translate(new Vec3(( -level.width >> 1), ( -level.height >> 1), 0), new Mat4());
		
		var view = new Mat4();
		Mat4.identity(view);
		GLM.translate(new Vec3(0, 0, -5), view);
		
		var projection = new Mat4();
		GLM.perspective(degRad(90), info.game.viewportSize.aspect, 0.1, 300, projection);
		
		var mv:Mat4 = view * model;
		var mvp = projection * mv;

		GL.uniform1f(timeUniform, info.time);
		GL.uniform4f(resolutionUniform,
					 info.game.viewportSize.width, info.game.viewportSize.height,
					 level.width, level.height
					);
					
					
		var normalMatrix = mv.toMat3();
		Mat3.invert(normalMatrix, normalMatrix);
		Mat3.transpose(normalMatrix, normalMatrix);
		
		GL.uniformMatrix4fv(matrixUniform, 1, false, new Float32Array(mvp.toFloatArray()));
		GL.uniformMatrix4fv(viewMatrixUniform, 1, false, new Float32Array(view.toFloatArray()));
		GL.uniformMatrix4fv(modelViewMatrixUniform, 1, false, new Float32Array(mv.toFloatArray()));
		GL.uniformMatrix4fv(modelMatrixUniform, 1, false, new Float32Array(model.toFloatArray()));
		GL.uniformMatrix3fv(normalMatrixUniform, 1, false, new Float32Array(normalMatrix.toFloatArray()));
		
		GL.drawElements(GL.TRIANGLES, indices.length, GL.UNSIGNED_SHORT, 0);

		var error:Int;
		while ((error = GL.getError()) != 0) {
			trace("GL error: " + error);
		}

		GL.disableVertexAttribArray(positionAttrib);
		GL.disableVertexAttribArray(normalAttrib);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		GL.useProgram(null);
		GL.disable(GL.DEPTH_TEST);
		GL.disable(GL.CULL_FACE);
	}

}