package coldBoot.entities;
import coldBoot.Level;
import coldBoot.states.GamePlayState;
import glm.Vec2;

class PulseTile
{
	public var intensity: Float;
	public var isWall: Bool;
	
	
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
	}
	
	public function update(info:UpdateInfo)
	{
		var decay = 0.1;
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];
				
				if (pt.intensity > 0)
				{
					var bleed = (pt.intensity - decay) * info.deltaTime;
					
					for (ny in 0...3)
					{
						for (nx in 0...3)
						{
							var neightborX = x + nx - 1;
							var neightborY = y + ny - 1;
							if (nx == x && ny == y)
								continue;
							if (neightborX < 0 || neightborX >= width)
								continue;
							if (neightborY < 0 || neightborY >= height)
								continue;
								
							var nb = pulseTiles[neightborY * width + neightborX];
							if (nb.isWall)
							{
								trace("Is wall: " + x + ", " + y);
								continue;
							}
							if (nb.intensity < pt.intensity)
								nb.intensity += bleed;
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
	
	var pulseIntensity: Float = 50;
	
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