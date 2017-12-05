package coldBoot.states;
import coldBoot.Entity;
import coldBoot.Game;
import coldBoot.UpdateInfo;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import tween.easing.Elastic;

class InitialState extends Sprite implements IGameState
{
	var initialized:Bool;
	public function new()
	{
		super();
    addChild(new Bitmap(Assets.getBitmapData("assets/c1.jpg")));
	}

	public function enter(g: Game): Void
	{
		g.stateSpriteContainer.addChild(this);
		alpha = 0;
		Delta.tween(this)
			.prop("alpha", 1, 1)
			.onComplete(beep)
			.wait(2)
			.prop("alpha", 0, 1)
			.onComplete(doneInitializing);
		trace("Entering initial state");
	}
	
	function beep():Void
	{
		trace("Bleep");
		#if AudioJank
		AudioJank.playSampleInSpace(AudioJank.SampleId.EnemyDialogueHigh3, 0.0, 0.0);
		#end
	}
	
	function doneInitializing() 
	{
		trace("Init");
		initialized = true;
	}

	public function update(info:UpdateInfo): IGameState
	{
		if (initialized) 
		{
			return info.game.setState(new GamePlayState());
		}
		return this;
	}

	public function render(info:RenderInfo): Void
	{

	}

	public function exit(g:Game): Void
	{
		trace("Exiting initial state");
		g.stateSpriteContainer.removeChild(this);
	}
	
	
	/* INTERFACE coldBoot.IGameState */
	
	public function getRootEntity():Entity 
	{
		return null;
	}
	
	
}
