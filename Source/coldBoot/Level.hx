package coldBoot;
import coldBoot.TileType;
import coldBoot.ai.PathFinding.GameMap;
import coldBoot.map.*;
import coldBoot.rendering.LevelRenderer;
import glm.Vec2;

class Level extends Entity
{
	var renderer:LevelRenderer;
	public var tiles: Array<TileType> = [];
	public var pixelSize = 10;
	public var width: Int;
	public var height: Int;

	public var map: GameMap;

	public function new(enemySpawnPoint: Vec2)
	{
		super();

		renderer = new LevelRenderer();

		var mapGenerator = MapGenerator.recursiveBacktracking(1, enemySpawnPoint, 16, 16);
		map = new coldBoot.ai.PathFinding.GameMap(
			mapGenerator.getWidth()*3,
			mapGenerator.getHeight()*3,
			pixelSize,
			function(idx)
		{
			return mapGenerator.getMap()[idx] == 0;
		});

		width = mapGenerator.getWidth() * 3;
		height = mapGenerator.getHeight() * 3;

		var tileMap = mapGenerator.getMap();

		renderer.init(this, tileMap);

		for (y in 0...height)
		{
			for (x in 0...width)
			{

				var coord = x + (y * width);
				var tile = tileMap[coord];
				if (tile == 0)
				{
					tiles.push(Air);
				}
				else
				{
					tiles.push(Wall);
				}
			}
		}

	}

	override public function render(info:RenderInfo)
	{
		renderer.render(info);
	}
}