package coldBoot;
import coldBoot.TileType;
import coldBoot.states.GamePlayState;


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
	}
	
	override public function render(state:GamePlayState) 
	{
		super.render(state);
		Main.debugDraw.graphics.beginFill(0x00ff00);
		
		for (w in tiles) {
			//w.render();
		}
		
	}
}