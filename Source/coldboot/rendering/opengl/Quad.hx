package coldboot.rendering.opengl;
import lime.graphics.opengl.*;
import lime.utils.Float32Array;

class Quad {
	
    static var vbo:GLBuffer;

    static function prepare(){
			if (vbo != null) GL.deleteBuffer(vbo);
				vbo = GL.createBuffer();
				
			var vertices:Array<Float> = [
				-1, -1, 0, 0,
				1, -1, 1, 0,
				1, 1, 1, 1,
				-1, 1, 0, 1
			];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
			GL.bufferData(GL.ARRAY_BUFFER, 4 * Float32Array.BYTES_PER_ELEMENT * vertices.length, new Float32Array(vertices), GL.STATIC_DRAW);
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }

    public static inline function bind(){
			if(vbo==null) prepare();
			GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
    }
		public static inline function draw(){
			GL.drawArrays(GL.TRIANGLE_FAN, 0, 4);
		}
    public static inline function release(){
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }
}