package coldBoot.rendering;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;

/**
 * ...
 * @author Andreas Rønning
 */
class LevelRenderer
{

	static var shader:LevelEntityShader;

	var buffer:GLBuffer;
	var vertexAttrib:Int;
	var resolutionUniform:GLUniformLocation;
	var vertices:Array<Float>;
	var matrixUniform:GLUniformLocation;
	var timeUniform:GLUniformLocation;
	var viewMatrixUniform:GLUniformLocation;
	var lightsUniform:GLUniformLocation;
	var level:Level;

	public function new()
	{
		if (shader==null)
			shader = new LevelEntityShader();

		vertexAttrib = shader.attribute("aVertex");
		resolutionUniform = shader.uniform("uResolution");
		matrixUniform = shader.uniform("uMatrix");
		viewMatrixUniform = shader.uniform("uView");
		timeUniform = shader.uniform("uTime");
		lightsUniform = shader.uniform("uLight0");

	}

	public function init(level:Level, map:Array<Int>)
	{
		this.level = level;
		vertices = [];

		function addVertAt(x:Int, y:Int, type:TileType)
		{
			var coord = (x + (y * level.width)) * 4;
			vertices[coord] = x;
			vertices[coord + 1] = y;
			vertices[coord + 2] = level.pixelSize;
			vertices[coord + 3] = switch (type)
			{
				case Air:
					0.0;
				case Wall:
					1.0;
			}
		}
		
		for (y in 0...level.height)
		{
			for (x in 0...level.width)
			{
				var coord = x + (y * level.width);
				var tile = map[coord];
				if (tile == 0)
				{
					addVertAt(x, y, Air);
				}
				else
				{
					addVertAt(x, y, Wall);
				}
			}
		}

		buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * vertices.length, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function render(info:RenderInfo)
	{
		GL.clearColor(0, 0, 0, 1);
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.enableVertexAttribArray(vertexAttrib);
		shader.bind();

		function degRad(deg:Float)
		{
			return deg * 3.14 / 180;
		}

		var transform = new Mat4();
		Mat4.identity(transform);
		transform *= GLM.translate(new Vec3(0, 0, -1), new Mat4());
		var t = info.time * 0.05;
		transform *= GLM.rotate(Quat.fromEuler(degRad( -40) + Math.sin(t) * 0.1, 0, t, new Quat()), new Mat4());

		var view = new Mat4();
		GLM.perspective(degRad(60), info.game.viewportSize.aspect, 0.1, 300, view)  ;

		GL.vertexAttribPointer(vertexAttrib, 4, GL.FLOAT, false, 0, 0);

		GL.enable(GL.VERTEX_PROGRAM_POINT_SIZE);
		GL.enable(GL.POINT_SPRITE);
		GL.enable(GL.DEPTH_TEST);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.depthFunc(GL.LESS);

		GL.uniform1f(timeUniform, info.time);
		GL.uniform4f(resolutionUniform,
					 info.game.viewportSize.width, info.game.viewportSize.height,
					 level.width, level.height
					);
		GL.uniform4f(lightsUniform,
					 level.width*0.5, level.height*0.5,
					 0, 0
					);

		GL.uniformMatrix4fv(matrixUniform, 1, false, new Float32Array(transform.toFloatArray()));
		GL.uniformMatrix4fv(viewMatrixUniform, 1, false, new Float32Array(view.toFloatArray()));
		GL.drawArrays(GL.POINTS, 0, Std.int(vertices.length/4));

		var error:Int;
		while ((error = GL.getError()) != 0)
		{
			trace("GL error: " + error);
		}

		GL.disable(GL.VERTEX_PROGRAM_POINT_SIZE);
		GL.disable(GL.POINT_SPRITE);
		GL.disable(GL.DEPTH_TEST);
	}

}