package coldBoot;
import coldBoot.states.GamePlayState;


class Level extends Entity
{
	public var levelData: Array<Wall> = [];
	public var tileSize = 60;
	
	public function new() 
	{
		super();
		var ld = [
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 1, 1, 0, 1, 1, 1, 1],
			[1, 0, 1, 1, 0, 1, 1, 1, 1],
			[1, 0, 1, 1, 0, 1, 1, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 1, 1], 
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1]
		];
		
		for (y in 0...ld.length)
		{
			for (x in 0...ld[y].length)
			{
				if (ld[y][x] == 1)
					levelData.push(new Wall(x * tileSize, y * tileSize, tileSize, tileSize));
			}
		}
	}
	
	override public function render(info:RenderInfo) 
	{
		super.render(info);
		Main.debugDraw.graphics.beginFill(0x00ff00);
		
		for (w in levelData)
			w.render();
		
	}
}