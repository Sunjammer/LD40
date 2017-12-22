package coldboot.rendering.opengl;
import lime.graphics.opengl.*;
import glm.*;
import lime.utils.Float32Array;
enum SymbologyCmd{
    Point(x:Float, y:Float, size:Float, opacity:Float);
    Circle(x:Float, y:Float, width:Float, height:Float, fill:Bool, opacity:Float);
    Triangle(x:Float, y:Float, width:Float, height:Float, rotation:Float, fill:Bool, opacity:Float);
    Square(x:Float, y:Float, width:Float, height:Float, rotation:Float, fill:Bool, opacity:Float);
    /*Cross(x:Float, y:Float, width:Float, height:Float, rotation:Float);
    Line(x1:Float, y1:Float, x2:Float, y2:Float);*/
}
class Symbology
{
    static inline var DEFAULT_LINE_WIDTH:Int = 2;

    static var cmds:Array<SymbologyCmd>;
    static var vertBuffer:GLBuffer;
    static var initialized:Bool; 
    static var shader:Shader;
    static var aPosition:Int;
    static var aInfo:Int;
    static var uScreenSize:GLUniformLocation;

    static function initialize(){
        vertBuffer = GL.createBuffer();
        shader = new Shader([Vertex("assets/shaders/symbology.vert"), Fragment("assets/shaders/symbology.frag")], "Symbology");

        uScreenSize = shader.getUniform("uScreenSize");
        aPosition = shader.getAttribute("aPosition");
        aInfo = shader.getAttribute("aInfo");
        initialized = true;
    }

    public static function beginFrame()
    {
        if(!initialized) 
            initialize();
        cmds = [];
    }

    public static function draw(width:Float, height:Float){
        if(cmds==null || cmds.length==0) 
            return;
        shader.bind();
        GL.disable(GL.CULL_FACE);
        GL.disable(GL.DEPTH_TEST);
        GL.enable(GL.POINT_SPRITE);
        GL.enable(GL.VERTEX_PROGRAM_POINT_SIZE);
        GL.uniform2f(uScreenSize, width, height);
        GL.bindBuffer(GL.ARRAY_BUFFER, vertBuffer);
        GL.enableVertexAttribArray(aPosition);
        GL.vertexAttribPointer(aPosition, 2, GL.FLOAT, false, 16, 0);
        GL.enableVertexAttribArray(aInfo);
        GL.vertexAttribPointer(aInfo, 2, GL.FLOAT, false, 16, 8);

        for(c in cmds)
            exec(c);

        shader.release();
        GL.disable(GL.VERTEX_PROGRAM_POINT_SIZE);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        GL.disableVertexAttribArray(aPosition);
    }

    static inline function exec(cmd:SymbologyCmd){
        var verts:Array<Float>; //2 floats per vert, xy
        GL.lineWidth(DEFAULT_LINE_WIDTH);
        switch(cmd){
            case Point(x,y,size,opacity):
                verts = [x, y, size, opacity];
                GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * verts.length, new Float32Array(verts), GL.DYNAMIC_DRAW);
                GL.drawArrays(GL.POINTS, 0, 1);
            case Circle(x,y,w,h,fill,opacity):
                var resolution = 32;
                var hh = h * 0.5;
                var hw = w * 0.5;
                verts = [];
                var offset = 0;
                for(i in 0...resolution){
                    var t = i/resolution;
                    verts[offset] = x + Math.cos(t * 6.28) * hw;
                    verts[1+offset] = y + Math.sin(t * 6.28) * hh;
                    verts[2+offset] = 0.0;
                    verts[3+offset] = opacity;
                    offset += 4;
                }
                GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * verts.length, new Float32Array(verts), GL.DYNAMIC_DRAW);
                GL.drawArrays(fill?GL.TRIANGLE_FAN:GL.LINE_LOOP, 0, Std.int(verts.length / 4));
            case Triangle(x,y,w,h,rot,fill,opacity):
                var hh = h * 0.5;
                var hw = w * 0.5;
                verts = [
                    x, y - hh, 0, opacity,
                    x + hw, y + hh, 0, opacity,
                    x - hw, y + hh, 0, opacity
                ];
                GL.lineWidth(4);
                GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * verts.length, new Float32Array(verts), GL.DYNAMIC_DRAW);
                GL.drawArrays(fill?GL.TRIANGLE_FAN:GL.LINE_LOOP, 0, Std.int(verts.length / 4));
            case Square(x,y,w,h,rot,fill,opacity):
                var hh = h * 0.5;
                var hw = w * 0.5;
                verts = [
                    x-hw, y-hh, 0, opacity,
                    x+hw, y-hh, 0, opacity,
                    x+hw, y+hh, 0, opacity,
                    x-hw, y+hh, 0, opacity
                ];
                GL.bufferData(GL.ARRAY_BUFFER, Float32Array.BYTES_PER_ELEMENT * verts.length, new Float32Array(verts), GL.DYNAMIC_DRAW);
                GL.drawArrays(fill?GL.TRIANGLE_FAN:GL.LINE_LOOP, 0, Std.int(verts.length / 4));
        }
    }

    public static function point(x:Float, y:Float, size:Float, opacity:Float = 1.0){
        cmds.push(Point(x, y, size, opacity));
    }
    public static function circle(x:Float, y:Float, radius:Float, fill:Bool = false, opacity:Float = 1.0){
        cmds.push(Circle(x, y, radius, radius, fill, opacity));
    }
    public static function triangle(x:Float, y:Float, width:Float, height:Float, rotation:Float, fill:Bool = false, opacity:Float = 1.0){
        cmds.push(Triangle(x,y,width,height,rotation, fill, opacity));
    }
    public static function square(x:Float, y:Float, width:Float, height:Float, rotation:Float, fill:Bool = false, opacity:Float = 1.0){
        cmds.push(Square(x,y,width,height,rotation, fill, opacity));
    }
}