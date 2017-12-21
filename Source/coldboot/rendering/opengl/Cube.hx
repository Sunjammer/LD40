package coldboot.rendering.opengl;
import lime.graphics.opengl.GL;
import lime.utils.UInt16Array;
import lime.utils.Float32Array;
import lime.graphics.opengl.*;

class Cube {
	public static var verts:Array<Float>;
	public static var vertexNormals:Array<Float>;
	public static var indices:Array<Int>;

	public var ibo:GLBuffer;
	public var vbo:GLBuffer;
	public var nbo:GLBuffer; // Yes i'm putting all normals in a buffer what of it WHAT OF IT
	public function new(){
		build();
		ibo = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, ibo);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, UInt16Array.BYTES_PER_ELEMENT * indices.length, new UInt16Array(indices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

		vbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * verts.length, new Float32Array(verts), GL.STATIC_DRAW);

		nbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, nbo);
		GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * vertexNormals.length, new Float32Array(vertexNormals), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function dispose(){
		GL.deleteBuffer(ibo);
		GL.deleteBuffer(vbo);
		GL.deleteBuffer(nbo);
	}
	
	public static function build() {
		if (verts != null) return;
		verts = [
		  // Front face
		  -1.0, -1.0,  1.0, 1,
		   1.0, -1.0,  1.0, 1,
		   1.0,  1.0,  1.0, 1,
		  -1.0,  1.0,  1.0, 1,

		  // Back face
		  -1.0, -1.0, -1.0, 1,
		  -1.0,  1.0, -1.0, 1,
		   1.0,  1.0, -1.0, 1,
		   1.0, -1.0, -1.0, 1,

		  // Top face
		  -1.0,  1.0, -1.0, 1,
		  -1.0,  1.0,  1.0, 1,
		   1.0,  1.0,  1.0, 1,
		   1.0,  1.0, -1.0, 1,

		  // Bottom face
		  -1.0, -1.0, -1.0, 1,
		   1.0, -1.0, -1.0, 1,
		   1.0, -1.0,  1.0, 1,
		  -1.0, -1.0,  1.0, 1,

		  // Right face
		   1.0, -1.0, -1.0, 1,
		   1.0,  1.0, -1.0, 1,
		   1.0,  1.0,  1.0, 1,
		   1.0, -1.0,  1.0, 1,

		  // Left face
		  -1.0, -1.0, -1.0, 1,
		  -1.0, -1.0,  1.0, 1,
		  -1.0,  1.0,  1.0, 1,
		  -1.0,  1.0, -1.0, 1
		];
		
		vertexNormals = [
			// Front face
			0.0,  0.0,  1.0, 0,
			0.0,  0.0,  1.0, 0,
			0.0,  0.0,  1.0, 0,
			0.0,  0.0,  1.0, 0,

			// Back face
			0.0,  0.0, -1.0, 0,
			0.0,  0.0, -1.0, 0,
			0.0,  0.0, -1.0, 0,
			0.0,  0.0, -1.0, 0,

			// Top face
			0.0,  1.0,  0.0, 0,
			0.0,  1.0,  0.0, 0,
			0.0,  1.0,  0.0, 0,
			0.0,  1.0,  0.0, 0,

			// Bottom face
			0.0, -1.0,  0.0, 0,
			0.0, -1.0,  0.0, 0,
			0.0, -1.0,  0.0, 0,
			0.0, -1.0,  0.0, 0,

			// Right face
			1.0,  0.0,  0.0, 0,
			1.0,  0.0,  0.0, 0,
			1.0,  0.0,  0.0, 0,
			1.0,  0.0,  0.0, 0,

			// Left face
			-1.0,  0.0,  0.0, 0,
			-1.0,  0.0,  0.0, 0,
			-1.0,  0.0,  0.0, 0,
			-1.0,  0.0,  0.0, 0
		];

		indices =[
			0, 1, 2,      0, 2, 3,    // Front face
			4, 5, 6,      4, 6, 7,    // Back face
			8, 9, 10,     8, 10, 11,  // Top face
			12, 13, 14,   12, 14, 15, // Bottom face
			16, 17, 18,   16, 18, 19, // Right face
			20, 21, 22,   20, 22, 23  // Left face
		];
	}

}