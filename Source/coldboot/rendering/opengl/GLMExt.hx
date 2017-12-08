package coldboot.rendering.opengl;
import glm.Mat3;
import glm.Mat4;

/**
 * ...
 * @author Andreas Kennedy
 */
class GLMExt {

	public static inline function toMat3(from:Mat4):Mat3{
		var out = new Mat3();
		out.r0c0 = from.r0c0;
		out.r0c1 = from.r0c1;
		out.r0c2 = from.r0c2;
		out.r1c0 = from.r1c0;
		out.r1c1 = from.r1c1;
		out.r1c2 = from.r1c2;
		out.r2c0 = from.r2c0;
		out.r2c1 = from.r2c1;
		out.r2c2 = from.r2c2;
		return out;
	}
	
}