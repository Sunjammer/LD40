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
	public var intensities: Map<Int,Float>;
	public var isWall: Bool;
	
	public function new(isWall: Bool = false) {
		this.intensities = new Map();
		this.isWall = isWall;
	}
	
	public function setIntensity(id: Int, intensity: Float)
	{
		this.intensities.set(id, intensity);
	}
	
	public function getIntensity(id: Int) : Float
	{
		if (!this.intensities.exists(id)) 
			return 0;
		var ret = this.intensities.get(id);
		return ret;
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
	
	public function startPulse(x: Int, y: Int, intensity: Float, type: Int) 
	{
		trace("Starting pulse: " + type);
		var pt = pulseTiles[x + (y * width)];
		pt.setIntensity(type, intensity);
	}
	
	public function checkTile(x: Int, y: Int, type: Int): Float
	{
		var pt = pulseTiles[x + (y * width)];
		return pt.getIntensity(type);
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
				
				for (k in pt.intensities.keys())
				{
					if (pt.getIntensity(k) > 0.1)
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
									
								var c = 0;
								
								var ni = neighbor.getIntensity(k);
								var pi = pt.getIntensity(k);
								//trace("Pi: " + pi);
								//trace("Dt: " + dt);
								var inc = (pi * dt * decay);
								//trace("Inc: " + inc);
								var newIntensity = ni + inc;
								//trace("New intensity: " + newIntensity);
								neighbor.setIntensity(k, newIntensity);
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
		tileBuffer.startPulse(x, y, intensity, type);
	}
	
	public function checkTile(x: Int, y: Int, type: Int): Float
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
				for (k in pt.intensities.keys())
				{
					Main.debugDraw.graphics.beginFill(colors[k], pt.getIntensity(k) / 40);
					Main.debugDraw.graphics.drawRect(x * level.pixelSize, y * level.pixelSize, level.pixelSize, level.pixelSize);
				}
			}
		}
	}
}