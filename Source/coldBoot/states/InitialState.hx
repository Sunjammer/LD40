package coldBoot.states;
import coldBoot.Game;
import coldBoot.UpdateInfo;
import openfl.display.Shape;
import tween.Delta;
import tween.easing.Elastic;

class InitialState extends Shape implements IGameState
{
	var initialized:Bool;
	public function new()
	{
		super();
		graphics.beginFill(0xff0000);
		graphics.drawCircle(100, 100, 100);
	}

	public function enter(g: Game): Void
	{
		g.spriteContainer.addChild(this);
		alpha = 0;
		Delta.tween(this).prop("alpha", 1, 0.1).ease(Elastic.easeIn).onComplete(doneInitializing);
		trace("Entering initial state");
	}
	
	function doneInitializing() 
	{
		initialized = true;
	}

	public function update(info:UpdateInfo): IGameState
	{
		if (initialized) 
		{
			var gamePlayState = new GamePlayState();
			info.game.setState(gamePlayState);
			return gamePlayState;
		}
		return this;
	}

	public function render(info:RenderInfo): Void
	{

	}

	public function exit(g:Game): Void
	{
		trace("Exiting initial state");
		g.spriteContainer.removeChild(this);
	}
}
