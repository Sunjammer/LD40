package coldBoot.entities;
import coldBoot.Level;
import coldBoot.entities.PulseMap.Intensity;
import glm.Vec2;

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

class Intensity
{
	public var type: Int;
	public var intensity: Float;
	public var direction: Vec2;
	
	public function new(type: Int, intensity: Float, direction: glm.Vec2)
	{
		this.type = type;
		this.intensity = intensity;
		this.direction = direction;
	}
}

class PulseTile
{
	public var pulses: Map<Int,Intensity>;
	public var isWall: Bool;
	
	public function new(isWall: Bool = false) {
		this.pulses = new Map();
		this.isWall = isWall;
	}
	
	public function setPulse(pulseId: Int, intensity: Intensity)
	{
		this.pulses.set(pulseId, intensity);
	}
	
	public function getPulse(pulseId: Int) : Intensity
	{
		if (!this.pulses.exists(pulseId))
			return null;
		var ret = this.pulses.get(pulseId);
		return ret;
	}
}

class PulseTileBuffer
{
	public var pulseTiles: Array<PulseTile> = [];
	var width: Int;
	var height: Int;
	
	var decay = 5.0;
	
	var pulsesIdCounter = 0;
	var pulsesTimers: Map<Int, Float> = new Map();
	
	public function new(level: Level)
	{
		width = level.width;
		height = level.height;
		
		for (y in 0...level.height)
		{
			for (x in 0...level.width)
			{
				var tileType = level.tiles[y * width + x];
				pulseTiles.push(new PulseTile(tileType == Wall));
			}
		}
	}
	
	public function startPulse(x: Int, y: Int, type: Int, intensity: Float): Int
	{
		var pt = pulseTiles[x + (y * width)];
		var id = pulsesIdCounter;
		pt.setPulse(id, new Intensity(type, intensity, new Vec2(0,0)));
		pulsesIdCounter++;
		pulsesTimers.set(id, 1.0);
		return id;
	}
	
	public function checkTile(x: Int, y: Int, pulseId: Int): Intensity
	{
		var pt = pulseTiles[x + (y * width)];
		return pt.getPulse(pulseId);
	}
	
	var rmCount = 0;
	public function update(info:UpdateInfo)
	{
		var dt = info.deltaTime;
		
		for (k in pulsesTimers.keys())
		{
			var t = pulsesTimers[k];
			pulsesTimers[k] = t - dt;
		}
		
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];
				
				for (k in pt.pulses.keys())
				{
					if (pulsesTimers[k] <= 0)
					{
						pt.pulses.remove(k);
						continue;
					}
					
					var ptPulse = pt.getPulse(k);
					if (ptPulse.intensity > 0.1)
					{
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
								
								var ni = neighbor.getPulse(k);
								if (ni == null)
								{
									ni = new Intensity(ptPulse.type, 0, new Vec2(nx - 1, ny - 1));
									neighbor.setPulse(k, ni);
								}
								
								var inc = (ptPulse.intensity * dt * decay);
								var newIntensity = ni.intensity + inc;
								ni.intensity = newIntensity;
							}
						}
					}
				}
			}
		}
		/*for (k in pulsesTimers.keys())
		{
			var t = pulsesTimers[k];
			if (t <= 0)
			{
				pulsesTimers.remove(k);
			}
		}*/
	}
}

class PulseMap extends Entity
{
	var strength: Float; //how long the pulse exists
	var timeSinceLaunch: Float = 0;
	var level:Level;
	
	var tileBuffer: PulseTileBuffer;
	
	public function new(level: Level)
	{
		super();
		this.level = level;
		tileBuffer = new PulseTileBuffer(level);
		
	}
	
	public function startPulse(x: Int, y: Int, intensity: Float, type: Int) 
	{
		tileBuffer.startPulse(x, y, type, intensity);
	}
	
	public function checkTile(x: Int, y: Int, type: Int): Intensity
	{
		return tileBuffer.checkTile(x, y, type);
	}

	override public function onAdded()
	{
		super.onAdded();
	}

	override public function update(info:UpdateInfo)
	{
		tileBuffer.update(info);
	}

	override public function render(info:RenderInfo)
	{
		super.render(info);
		var colors = [
			0xff0000,
			0x00ff00,
			0xff00ff,
			0xffff00,
			0x00ffff
		];
		for (y in 0...level.height){
			for (x in 0...level.width)
			{
				var pt = tileBuffer.pulseTiles[y * level.width + x];
				for (k in pt.pulses.keys())
				{
					var pulse = pt.getPulse(k);
					Main.debugDraw.graphics.beginFill(colors[pulse.type], pulse.intensity / 40);
					Main.debugDraw.graphics.drawRect(x * level.pixelSize, y * level.pixelSize, level.pixelSize, level.pixelSize);
				}
			}
		}
	}
}