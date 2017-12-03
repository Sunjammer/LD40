package coldBoot;
import coldBoot.TileType;
import coldBoot.entities.*;
import coldBoot.map.*;
import glm.Vec2;

class Level extends Entity
{
	public var tiles: Array<TileType> = [];
	public var pixelSize = 20;
	public var width: Int;
	public var height: Int;
	

	public function new() 
	{
		super();

		var enemySpawnPoint = new glm.Vec2(1,1);
		var mapGenerator = MapGenerator.recursiveBacktracking(1, enemySpawnPoint, 16, 16);
		var map = new coldBoot.ai.PathFinding.GameMap(
			mapGenerator.getWidth()*3,
			mapGenerator.getHeight()*3,
			pixelSize,
			function(idx) {
				return mapGenerator.getMap()[idx] == 0;
			});

		for(i in 0...50) {
			add(new coldBoot.entities.Enemy(map, enemySpawnPoint * (pixelSize * 3) - (pixelSize * 3) / 2 + 1));
		}
		
		width = mapGenerator.getWidth() * 3;
		height = mapGenerator.getHeight() * 3;
		
		var map = mapGenerator.getMap();
		
		for (y in 0...height)
		{
			for (x in 0...width)
			{
			
				var tile = map[x + (y * width)];
				trace("Tile: " + tile);
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
		
		for (x in 0...width)
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
					Main.debugDraw.graphics.beginFill(0xff0000);
					Main.debugDraw.graphics.drawRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
				}
			}
		}
	}
}