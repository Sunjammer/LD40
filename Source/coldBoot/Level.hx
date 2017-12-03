package coldBoot;
import coldBoot.TileType;
import coldBoot.states.GamePlayState;
import coldBoot.map.*;
import coldBoot.entities.*;
import openfl.display.Bitmap;

class Level extends Entity
{
	public var tiles: Array<TileType> = [];
	public var tileSize = 60;
	public var width: Int;
	public var height: Int;
	

	public function new() 
	{
		super();
		var ld = [
			[1, 1, 1, 1, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 0, 0, 0, 0],
			[1, 0, 1, 0, 1, 1, 1, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0]
		];
		
		width = ld[0].length;
		height = ld.length;
		
		for (y in 0...ld.length)
		{
			for (x in 0...ld[y].length)
			{
				if (ld[y][x] == 1)
					tiles.push(TileType.Wall);
				else
					tiles.push(TileType.Air);
			}
		}

		var enemySpawnPoint = new glm.Vec2(1,1);
		var pixelSize = 20;
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
		var bitmap = mapGenerator.getBitmap();
		bitmap.width *= pixelSize;
		bitmap.height *= pixelSize;
		Main.debugDraw.addChild(bitmap);
	}
	
	/*override public function render(info:RenderInfo) 
	{
		super.render(info);
		info.game.addChild bitmap
		/*Main.debugDraw.graphics.beginFill(0x00ff00);
		
		for (w in tiles) {
			//w.render();
		}
		
	}*/
}