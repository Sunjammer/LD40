package coldBoot.entities;
import coldBoot.Level;

class Index 
{
	public var x: Int;
	public var y: Int;
	public function new (x: Int, y:Int)
	{
		this.x = x;
		this.y = y;
	}
}

class PulseTile
{
	public var intensity: Float;
	public var isWall: Bool;
	var hasBeenAffectedByArray: Array<Index> = [];
	
	public function new(intensity: Float = 0, isWall: Bool = false) {
		this.intensity = intensity;
		this.isWall = isWall;
	}
	
}

class PulseTileBuffer
{
	public var pulseTiles: Array<PulseTile> = [];
	var width: Int;
	var height: Int;
	
	public var life: Float;
	
	public function new(level: Level, life: Float)
	{
		this.life = life;
		width = level.width;
		height = level.height;
		
		for (y in 0...level.height)
		{
			for (x in 0...level.width)
			{
				var tileType = level.tiles[y * width + x];
				pulseTiles.push(new PulseTile(0, tileType == Wall));
			}
		}
	}
	
	public function startPulse(x: Int, y: Int, intensity: Float) 
	{
		var pt = pulseTiles[x + (y * width)];
		pt.intensity = intensity;
	}
	
	public function update(info:UpdateInfo)
	{
		var dt = info.deltaTime;
		life -= dt;
		var decay = 2;
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];

				for (ny in 0...3)
				{
					for (nx in 0...3)
					{
						var neighborX = nx - 1 + x;
						var neighborY = ny - 1 + y;
						if (neighborX < 0 || neighborX >= width || neighborY < 0 || neighborY >= height || (neighborX == x && neighborY == y))
							continue;
							
						var neighbor = pulseTiles[neighborX + (neighborY * width)];
						
						if (neighbor.isWall)
							continue;// neighbor.intensity += pt.intensity * wallBleed * dt;
						 
						neighbor.intensity += pt.intensity * dt * decay;
					}
				}
			}
		}
	}
}

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 0.58;
	var timeSinceLaunch: Float = 0;
	var level:Level;
	
	var pulseIntensity: Float = 50;
	
	var tileBuffer: PulseTileBuffer;
	
	public function new(level: Level)
	{
		super();
		this.level = level;
		tileBuffer = new PulseTileBuffer(level, 3);
		tileBuffer.startPulse(19, 19, pulseIntensity);
	}

	override public function onAdded()
	{
		super.onAdded();
	}

	override public function update(info:UpdateInfo)
	{
		super.update(info);
		tileBuffer.update(info);
		if (tileBuffer.life <= 0)
		{
			tileBuffer = new PulseTileBuffer(level, 3);
			tileBuffer.startPulse(19, 19, pulseIntensity);
		}
	}

	override public function render(info:RenderInfo)
	{
		super.render(info);
		for (y in 0...level.height){
			for (x in 0...level.width)
			{
				var pt = tileBuffer.pulseTiles[y * level.width + x];
				if (pt == null)
					continue;
				Main.debugDraw.graphics.beginFill(0xff0000, pt.intensity / pulseIntensity);
				Main.debugDraw.graphics.drawRect(x * level.pixelSize, y * level.pixelSize, level.pixelSize, level.pixelSize);
			}
		}
	}
}