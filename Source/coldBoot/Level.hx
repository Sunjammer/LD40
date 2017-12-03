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
		/*var bitmap = mapGenerator.getBitmap();
		bitmap.width *= pixelSize;
		bitmap.height *= pixelSize;*/
		
		width = mapGenerator.getWidth();
		height = mapGenerator.getHeight();
		
		var map = mapGenerator.getMap();
		
		for (x in 0...width)
		{
			for (y in 0...height)
			{
				var tile = map[x + (y * width)];
				trace("Tile: " + tile);
				if (tile == 1)
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
		
		trace("Rendering level");
		
		Main.debugDraw.graphics.beginFill(0x000000);
		for (x in 0...width)
		{
			for (y in 0...height)
			{
				var tile = tiles[x + (y * width)];
				if (tile == Wall)
				{
					trace("Drwaing shit");
					Main.debugDraw.graphics.drawRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
				}
			}
		}
	}
}