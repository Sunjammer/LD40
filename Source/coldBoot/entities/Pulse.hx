package coldBoot.entities;
import coldBoot.Level;
import coldBoot.states.GamePlayState;

class PulseTile
{
	public var intensity: Float = 20;
	
	
	public function new() 
	{
		
	}
}

class Pulse extends Entity
{
	var strength: Float; //how long the pulse exists
	var speed: Float = 0.58;
	var timeSinceLaunch: Float = 0;
	var level:Level;
	
	var pulseTiles: Array<PulseTile> = [];

	public function new(level: Level)
	{
		super();
		this.level = level;
	}

	override public function onAdded()
	{
		super.onAdded();
	}

	override public function update(state:GamePlayState, dt:Float)
	{
		super.update(state, dt);
		
		var decay = 0.1;
		for (y in 0...level.height)
		{
			for (x in 0...level.width)
			{
				var pt = pulseTiles[y * level.width + x];
				
				if (pt.intensity > 0)
				{
					var nextIntensity = pt.intensity - decay;
					
					for (nx in -1...1)
					{
						for (ny in -1...1)
						{
							if (nx == x && ny == y)
								continue;
							var nb = pulseTiles[(y + ny) * level.width + (x + nx)];
							if (nb.intensity < pt.intensity)
								nb.intensity = nextIntensity;
						}
					}
				}
			}
		}
	}

	override public function render(state:GamePlayState)
	{
		super.render(state);
		for (y in 0...level.height)
		{
			for (x in 0...level.width)
			{
				var pt = pulseTiles[y * level.width + x];
				Main.debugDraw.graphics.beginFill(0xff0000, pt.intensity / 20.0);
				Main.debugDraw.graphics.drawRect(x * 60, y * 60, 60, 60);
			}
		}
	}
}