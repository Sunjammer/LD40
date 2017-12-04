package coldBoot.rendering;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import openfl.gl.*;

typedef ShaderSource =
{
	var src:String;
	var fragment:Bool;
}

/**
 * GLSL Shader object
 */
class Shader
{

	public static var allShaders(default,never):Array<Shader> = [];
	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(sources:Array<ShaderSource>, name:String="Shader")
	{
		this.name = name;
		allShaders.push(this);
		this.sources = sources;
		rebuild();
	}

	public function rebuild()
	{
		if (program != null)
			GL.deleteProgram(program);
		program = GL.createProgram();
		for (source in sources)
		{
			var shader = compile(source.src, source.fragment ? GL.FRAGMENT_SHADER : GL.VERTEX_SHADER);
			if (shader == null) return;
			GL.attachShader(program, shader);
			GL.deleteShader(shader);
		}

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			trace(GL.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + GL.getProgramParameter(program, GL.VALIDATE_STATUS));
			trace("ERROR: " + GL.getError());
			return;
		}
		else
		{
			trace("Successfully linked shader "+name);
		}
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private function compile(source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			trace(GL.getShaderInfoLog(shader));
			return null;
		}

		return shader;
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 */
	public inline function attribute(a:String):Int
	{
		return GL.getAttribLocation(program, a);
	}

	/**
	 * Return the uniform location in this shader
	 * @param a  The uniform name to find
	 */
	public inline function uniform(u:String):GLUniformLocation
	{
		return GL.getUniformLocation(program, u);
	}

	/**
	 * Bind the program for rendering
	 */
	public function bind()
	{
		GL.useProgram(program);
	}

	public function destroy()
	{
		GL.deleteProgram(program);
	}

	var sources:Array<ShaderSource>;
	private var program:GLProgram;
	var name:String;

}