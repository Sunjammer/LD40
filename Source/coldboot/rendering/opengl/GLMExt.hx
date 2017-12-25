package coldboot.rendering.opengl;
import glm.*;

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
	
    public static inline function rotate(vec:Vec2, angle:Float):Vec2{
        var cs = Math.cos(angle);
        var sn = Math.sin(angle);
        var px = vec.x * cs - vec.y * sn; 
        var py = vec.x * sn + vec.y * cs;
        return new Vec2(px, py);
    }
	
}