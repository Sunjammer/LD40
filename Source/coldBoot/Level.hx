package coldboot;
import coldboot.rendering.LevelRenderer;
import openfl.display.DisplayObjectContainer;
import coldboot.TileType;
import coldboot.entities.*;
import coldboot.map.*;
import coldboot.ai.PathFinding.GameMap;
import glm.Vec2;

class Level extends Entity
{
	public var tiles: Array<TileType> = [];
	public var pixelSize = 20;
	public var width: Int;
	public var height: Int;
	
	var renderer:LevelRenderer;
	
	public var map: GameMap;

	public function new(container:DisplayObjectContainer, enemySpawnPoint: Vec2) 
	{
		super();
		
		var mapGenerator = MapGenerator.recursiveBacktracking(1, enemySpawnPoint, 16, 16);
		map = new coldboot.ai.PathFinding.GameMap(
			mapGenerator.getWidth()*3,
			mapGenerator.getHeight()*3,
			pixelSize,
			function(idx) {
				return mapGenerator.getMap()[idx] == 0;
			});
		
		width = mapGenerator.getWidth() * 3;
		height = mapGenerator.getHeight() * 3;
		
		var tileMap = mapGenerator.getMap();
		
		#if ogl
		renderer = new LevelRenderer();
		renderer.init(this, tileMap);
		#end
		
		for (y in 0...height)
		{
			for (x in 0...width)
			{
			
				var tile = tileMap[x + (y * width)];
				if (tile == 0)
				{
					tiles.push(TileType.Air);
				}
				else
				{
					tiles.push(TileType.Wall);				
				}
			}
		}
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		#if ogl
		renderer.render(info);
		#end
		
		/*for (x in 0...width)
		{
			for (y in 0...height)
			{
				var tile = tiles[x + (y * width)];
				if (tile == Wall)
				{
					Main.debugDraw.graphics.beginFill(0x000000);
					Main.debugDraw.graphics.drawRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);

				}
				else 
				{
					Main.debugDraw.graphics.beginFill(0xffffff);
					Main.debugDraw.graphics.drawRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
				}
			}
		}*/
	}
}