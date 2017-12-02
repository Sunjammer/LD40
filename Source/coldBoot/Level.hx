package coldBoot;
import coldBoot.states.GamePlayState;


class Level extends Entity
{
	public var levelData: Array<Array<Int>>;
	public var tileSize = 40;
	
	public function new() 
	{
		super();
		levelData = [
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
	}
	
	override public function render(state:GamePlayState) 
	{
		super.render(state);
		Main.debugDraw.graphics.beginFill(0x00ff00);
		for (y in 0...levelData.length)
		{
			for (x in 0...levelData[y].length)
			{
				if (levelData[y][x] == 1)
					Main.debugDraw.graphics.drawRect(x * tileSize, y * tileSize, tileSize, tileSize);
			}
		}
	}
}