package coldBoot.entities;
import coldBoot.Level;
import coldBoot.entities.PulseMap.Intensity;

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
	public var pulseId: Int;
	public var type: Int;
	public var intensity: Float;
	public var life: Float;
	
	public function new(type: Int, intensity: Float, life: Float)
	{
		this.type = type;
		this.intensity = intensity;
		this.life = life;
	}
	
	public function update(dt: Float)
	{
		this.life -= dt;
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
	
	public function update(dt: Float)
	{
		for (k in pulses.keys())
		{
			var p = pulses[k];
			p.update(dt);
			if (p.life <= 0)
			{
				pulses.remove(k);
			}
		}
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
				pulseTiles.push(new PulseTile(tileType == Wall));
			}
		}
	}
	
	public function startPulse(x: Int, y: Int, type: Int, intensity: Float) 
	{
		var pt = pulseTiles[x + (y * width)];
		pt.setPulse(type, new Intensity(type, intensity, life));
	}
	
	public function checkTile(x: Int, y: Int, pulseId: Int): Intensity
	{
		var pt = pulseTiles[x + (y * width)];
		return pt.getPulse(pulseId);
	}
	
	public function update(info:UpdateInfo)
	{
		var dt = info.deltaTime;
		life -= dt;
		var decay = 1.0;
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];
				
				for (k in pt.pulses.keys())
				{
					var ptPulse = pt.getPulse(k);
					if (ptPulse.intensity > 0.1)
					{
						trace("Got some pulse at least: " + k + ", " + ptPulse.intensity);
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
									ni = new Intensity(ptPulse.type, 0, ptPulse.life);
									neighbor.setPulse(k, ni);
								}
									
								var pi = ptPulse;
								//trace("Pi: " + pi);
								//trace("Dt: " + dt);
								var inc = (pi.intensity * dt * decay);
								//trace("Inc: " + inc);
								var newIntensity = ni.intensity + inc;
								trace("New intensity: " + newIntensity);
								ni.intensity = newIntensity;
							}
						}
					}
				}
			}
		}
	}
}


class PulseMap extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 0.58;
	var timeSinceLaunch: Float = 0;
	var level:Level;
	
	var tileBuffer: PulseTileBuffer;
	
	public function new(level: Level)
	{
		super();
		this.level = level;
		tileBuffer = new PulseTileBuffer(level, 5);
		
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
		if (tileBuffer.life <= 0)
		{
			tileBuffer = new PulseTileBuffer(level, 5);
		}
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