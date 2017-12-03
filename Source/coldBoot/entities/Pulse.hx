package coldBoot.entities;
import coldBoot.Level;
import coldBoot.entities.Pulse.Index;
import coldBoot.entities.Pulse.PulseTile;
import glm.Vec2;
import haxe.ds.IntMap;

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
	public var index: Index;
	public var isWall: Bool;
	var hasBeenAffectedByArray: Array<Index> = [];
	
	public function new(index:Index, intensity: Float = 0, isWall: Bool = false) {
		this.index = index;
		this.intensity = intensity;
		this.isWall = isWall;
	}
	
	public function affect(pt: PulseTile)
	{
		if (this.hasBeenAffectedByArray.indexOf(pt.index) == -1)
		{
			this.hasBeenAffectedByArray.push(pt.index);
		}
	}
	
	public function hasBeenAffectedBy(pt: PulseTile): Bool
	{
		return this.hasBeenAffectedByArray.indexOf(pt.index) != -1;
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
				pulseTiles.push(new PulseTile(new Index(x,y), 0, tileType == Wall));
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
		var bleed = 0.1;
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var pt = pulseTiles[y * width + x];
				var amountBled = 0.0;
				
				if (pt.intensity > 0.5)
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
							
							if (pt.hasBeenAffectedBy(neighbor))
								continue;
							
							if (neighbor.isWall)
								continue; //neighbor.intensity += pt.intensity * wallBleed * dt;
							 
							var toBleed = pt.intensity * bleed * dt;
							neighbor.intensity += toBleed;
							amountBled += toBleed;
							neighbor.affect(pt);
						}
					}
				}
					
				pt.intensity -= amountBled;
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