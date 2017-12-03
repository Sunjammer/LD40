package coldBoot;
import coldBoot.TileType;
import coldBoot.entities.*;
import coldBoot.map.*;
import coldBoot.ai.PathFinding.GameMap;
import coldBoot.rendering.LevelEntityShader;
import coldBoot.rendering.Shader;
import glm.Vec2;
import haxe.Timer;
import lime.utils.Float32Array;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.DataPointer;

class Level extends Entity
{
	public var tiles: Array<TileType> = [];
	public var pixelSize = 20;
	public var width: Int;
	public var height: Int;
  
  static var shader:LevelEntityShader;
  var buffer:GLBuffer;
  var vertexAttrib:Int;
  var resolutionUniform:lime.graphics.opengl.GLUniformLocation;
	
	public var map: GameMap;

	public function new(enemySpawnPoint: Vec2) 
	{
		super();
    

		var mapGenerator = MapGenerator.recursiveBacktracking(1, enemySpawnPoint, 16, 16);
		map = new coldBoot.ai.PathFinding.GameMap(
			mapGenerator.getWidth()*3,
			mapGenerator.getHeight()*3,
			pixelSize,
			function(idx) {
				return mapGenerator.getMap()[idx] == 0;
			});
		
		width = mapGenerator.getWidth() * 3;
		height = mapGenerator.getHeight() * 3;
		
		var tileMap = mapGenerator.getMap();
    
    var vertices:Array<Float> = [];
    
    function addVertAt(x:Int, y:Int, type:TileType){
      var coord = (x + (y * width)) * 4;
      vertices[coord] = x / width;
      vertices[coord + 1] = y / height;
      vertices[coord + 2] = 1.0;
      vertices[coord + 3] = switch(type){
        case Air:
          0.0;
        case Wall:
          1.0;
      }
    }
		
		for (y in 0...height)
		{
			for (x in 0...width)
			{
			
        var coord = x + (y * width);
				var tile = tileMap[coord];
				if (tile == 0)
				{
					tiles.push(TileType.Air);
          addVertAt(x, y, TileType.Air);
				}
				else
				{
					tiles.push(TileType.Wall);	
          addVertAt(x, y, TileType.Wall);			
				}
			}
		}
    
    shader = new LevelEntityShader();
    vertexAttrib = shader.attribute("aVertex");
    resolutionUniform = shader.uniform("uResolution");
    
    buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.bufferData(GL.ARRAY_BUFFER, height*width*4, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}
	
	override public function render(info:RenderInfo) 
	{
    shader.bind();
    GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
    GL.enableVertexAttribArray(vertexAttrib);
    GL.vertexAttribPointer(vertexAttrib, width * height * 4, GL.FLOAT, false, 0, 0);
    GL.drawArrays(GL.POINTS, 0, width * height);
    
	}
}