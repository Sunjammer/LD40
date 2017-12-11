package coldboot.rendering.opengl;

import lime.graphics.opengl.*;

enum ShaderSource{
	Vertex(source:String);
	Fragment(source:String);
	Other(source:String, type:Int);
}

 @:build(coldboot.rendering.opengl.GLDebug.build())
class Shader {
	
	public var name:String;
	var program:GLProgram;
	var sources:Array<ShaderSource>;
	var linked:Bool;
	var isValid(get, never):Bool;
	public function new(sources:Array<ShaderSource>, descriptiveName:String = "Shader"){
		this.sources = sources;
		this.name = descriptiveName;
		build();
	}

	function get_isValid():Bool{
		return linked;
	}


	@gldebug
	public function build()
	{
		linked = false;
		destroy();
		program = GL.createProgram();
		var error = false;
		for (source in sources)
		{
			var shader:GLShader = switch(source){
				case Fragment(src):
					compile(src, GL.FRAGMENT_SHADER);
				case Vertex(src):
					compile(src, GL.VERTEX_SHADER);
				case Other(src, type):
					compile(src, type);
			}
			if(shader==null){
				error = true;
				break;
			}
			GL.attachShader(program, shader);
			GL.deleteShader(shader);
		}

		if(error){
			trace("Could not compile shaders for program "+name);
			destroy();
			return;
		}

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			trace(GL.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + GL.getProgramParameter(program, GL.VALIDATE_STATUS));
			trace(this.name+" ERROR: " + GL.getError());
			destroy();
			return;
		}

		linked = true;
		trace("Successfully linked program "+name);
	}

	private function compile(source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			trace(this.name+": "+GL.getShaderInfoLog(shader));
			return null;
		}

		return shader;
	}

	public inline function getAttribute(a:String):Int
	{
		return GL.getAttribLocation(program, a);
	}

	public inline function getUniform(u:String):GLUniformLocation
	{
		return GL.getUniformLocation(program, u);
	}

	public function bind()
	{
		GL.useProgram(program);
	}

	public function release()
	{
		GL.useProgram(null);
	}

	public function destroy()
	{
		GL.deleteProgram(program);
	}

}