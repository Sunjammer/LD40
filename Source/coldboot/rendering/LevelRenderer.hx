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

	var level:Level;

	static var shader:LevelShader;

	var vertices:Array<Float>;
	var offsets:Array<Float>;
	var indices:Array<Int>;

	var vertVbo:GLBuffer;
	var indexVbo:GLBuffer;
	var offsetVbo:GLBuffer;

	var positionAttrib:Int;
	var normalAttrib:Int;
	var offsetAttrib:Int;

	var resolutionUniform:GLUniformLocation;
	var timeUniform:GLUniformLocation;
	var viewMatrixUniform:GLUniformLocation;
	var lightsUniform:GLUniformLocation;
	var mvpMatrixUniform:GLUniformLocation;
	var modelMatrixUniform:GLUniformLocation;
	var normalMatrixUniform:GLUniformLocation;
	var modelViewMatrixUniform:GLUniformLocation;

	public function new() {
		if (shader==null)
			shader = new LevelShader("assets/distpattern.jpg");

		positionAttrib = shader.getAttribute("aPosition");
		normalAttrib = shader.getAttribute("aNormal");
		offsetAttrib = shader.getAttribute("aOffset");
		
		resolutionUniform = shader.getUniform("uResolution");
		mvpMatrixUniform = shader.getUniform("uMvp");
		modelViewMatrixUniform = shader.getUniform("uModelView");
		modelMatrixUniform = shader.getUniform("uModel");
		normalMatrixUniform = shader.getUniform("uNormal");
		viewMatrixUniform = shader.getUniform("uView");
		timeUniform = shader.getUniform("uTime");
	}

	@gldebug
	public function init(level:Level, map:Array<Int>) {
		this.level = level;
		vertices = []; //vec3 / vec3
		indices = []; //int
		offsets = []; //vec3

		Cube.build();
		
		var primCount = 0;
		inline function emitCube(x:Float, y:Float, z:Float, a:Float) {
			var i = 0;
			var k = offsets.length;
			var j = vertices.length;
			var rnd = Math.random() * 0.5;
			while (i < Cube.verts.length){
				//use half-cubes to fit grid unit
				vertices[j] = Cube.verts[i] * 0.5;
				vertices[j + 1] = Cube.verts[i + 1] * 0.5;
				vertices[j + 2] = Cube.verts[i + 2] * 0.5;
				vertices[j + 3] = Cube.verts[i + 3] * 0.5;
				
				vertices[j + 4] = Cube.vertexNormals[i];
				vertices[j + 5] = Cube.vertexNormals[i + 1];
				vertices[j + 6] = Cube.vertexNormals[i + 2];
				vertices[j + 7] = 0.0;

				offsets[k++] = x;
				offsets[k++] = y; 
				offsets[k++] = z + rnd;
				offsets[k++] = a;

				i += 4;
				j += 8;
			}

			i = 0;				
			j = indices.length;
			while (i < Cube.indices.length){
				indices[j + i] = Cube.indices[i] + primCount * 24;
				i++;
			}
			primCount++;
		}

		inline function addCubeAt(x:Float, y:Float, z:Float, type:TileType) {
			emitCube(x, y, z, switch (type) {
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
					addCubeAt(x, y, 0, Air);
				} else {
					addCubeAt(x, y, 0, Wall);
				}
			}
		}

		trace(level.width+", "+level.height);
		
		indexVbo = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexVbo);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, UInt16Array.BYTES_PER_ELEMENT * indices.length, new UInt16Array(indices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

		vertVbo = GL.createBuffer(); //vertices, normals
		GL.bindBuffer(GL.ARRAY_BUFFER, vertVbo);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * vertices.length, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
			
		offsetVbo = GL.createBuffer(); //per-cube position offsets and flags
		GL.bindBuffer(GL.ARRAY_BUFFER, offsetVbo);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * offsets.length, new Float32Array(offsets), GL.DYNAMIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	@gldebug
	public function render(info:RenderInfo) {
		var w = info.game.viewportSize.width-220;
		var h = info.game.viewportSize.height;
		GL.viewport (0, 0, w, h);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		
		GL.enable(GL.DEPTH_TEST);
		GL.depthFunc(GL.LESS);
		
		GL.enable(GL.CULL_FACE);
		GL.cullFace(GL.BACK);
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexVbo);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertVbo);
		GL.vertexAttribPointer(positionAttrib, 4, GL.FLOAT, false, 32, 0);
		GL.enableVertexAttribArray(positionAttrib);
		GL.vertexAttribPointer(normalAttrib, 4, GL.FLOAT, true, 32, 16);
		GL.enableVertexAttribArray(normalAttrib);

		GL.bindBuffer(GL.ARRAY_BUFFER, offsetVbo);
		GL.vertexAttribPointer(offsetAttrib, 4, GL.FLOAT, false, 0, 0);
		GL.enableVertexAttribArray(offsetAttrib);

		shader.bind();

		function degRad(deg:Float) {
			return deg * 3.14 / 180;
		}

		var model = new Mat4();
		Mat4.identity(model);
		var t = info.time * 0.05;
		
		var hh = level.height * 0.5;
		var hw = level.width * 0.5;

		model *= GLM.rotate(Quat.fromEuler(degRad(-30), 0, t, new Quat()), new Mat4());
		model *= GLM.translate(new Vec3(-level.width * 0.5, -level.height * 0.5), new Mat4());
		
		var view = new Mat4();
		Mat4.identity(view);
		view *= GLM.translate(new Vec3(0, 0, -level.height), new Mat4());
		
    	var projection = GLM.orthographic(-hw, hw, -hh, hh, 0.05, level.height*level.width, new Mat4());
		
		var mv:Mat4 = view * model;
		var mvp = projection * mv;
					
		var normalMatrix = mv.toMat3();
		Mat3.invert(normalMatrix, normalMatrix);
		Mat3.transpose(normalMatrix, normalMatrix);
		
		GL.uniformMatrix4fv(mvpMatrixUniform, 1, false, new Float32Array(mvp.toFloatArray()));
		GL.uniformMatrix4fv(viewMatrixUniform, 1, false, new Float32Array(view.toFloatArray()));
		GL.uniformMatrix4fv(modelViewMatrixUniform, 1, false, new Float32Array(mv.toFloatArray()));
		GL.uniformMatrix4fv(modelMatrixUniform, 1, false, new Float32Array(model.toFloatArray()));

		GL.uniformMatrix3fv(normalMatrixUniform, 1, true, new Float32Array(normalMatrix.toFloatArray()));

		GL.uniform1f(timeUniform, info.time);
		GL.uniform4f(resolutionUniform,
					 w, h,
					 level.width, level.height
					);


		GL.drawElements(GL.TRIANGLES, indices.length, GL.UNSIGNED_SHORT, 0);

		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

		GL.disableVertexAttribArray(positionAttrib);
		GL.disableVertexAttribArray(normalAttrib);
		GL.disableVertexAttribArray(offsetAttrib);
		
		GL.disable(GL.DEPTH_TEST);
		GL.disable(GL.CULL_FACE);

		shader.release();

		GL.viewport (0, 0, info.game.viewportSize.width, info.game.viewportSize.height);
	}

}