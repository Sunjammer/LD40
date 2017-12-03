package coldBoot.entities;
import coldBoot.Level;
import glm.Vec2;

class PulseTile
{
	public var intensity: Float;
	public var isWall: Bool;
	
	public var leftVel: Bool;
	public var rightVel: Bool;
	public var upVel: Bool;
	public var downVel: Bool;
	
	public function new(intensity: Float = 0, isWall: Bool = false) {
		this.intensity = intensity;
		this.isWall = isWall;
	}
	
	public function setVel(left: Bool, right: Bool, up: Bool, down: Bool)
	{
		leftVel = left;
		rightVel = right;
		upVel = up;
		downVel = down;
	}
}

class PulseTileBuffer
{
	public var pulseTiles: Array<PulseTile> = [];
	var width: Int;
	var height: Int;
	
	public function new(level: Level)
	{
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
		pt.setVel(true, true, true, true);
	}
	
	function isOutsideBounds(x:Int, y: Int): Bool
	{
		return x < 0 || x >= width
		 || y < 0 || y >= height;
	}
	
	public function update(info:UpdateInfo)
	{
		var decay = 0.001;
		var dt = info.deltaTime;

		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];
				
				if (pt.intensity > 0)
				{
					var bleed = (pt.intensity - decay) * dt;
					for (ny in 0...3)
					{
						for (nx in 0...3)
						{
							var neighborX = x + nx - 1;
							var neighborY = y + ny - 1;
							if (neighborX == x && neighborY == y)
								continue;
							if (isOutsideBounds(neighborX, neighborY))
								continue;
							
							var nb = pulseTiles[neighborY * width + neighborX];
							if (nb.isWall)
							{
								
							}
						}
					}
					for (ny in 0...3)
					{
						for (nx in 0...3)
						{
							var neighborX = x + nx - 1;
							var neighborY = y + ny - 1;
							if (nx == x && ny == y)
								continue;
							if (neighborX < 0 || neighborX >= width)
								continue;
							if (neighborY < 0 || neighborY >= height)
								continue;
							var nb = pulseTiles[neighborY * width + neighborX];
							if (nb.isWall)
								continue;
							
						}
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
	
	var pulseIntensity: Float = 500;
	
	var tileBuffer: PulseTileBuffer;
	
	public function new(level: Level)
	{
		super();
		this.level = level;
		tileBuffer = new PulseTileBuffer(level);
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