package coldBoot.states;
import coldBoot.Game;
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
		g.addChild(this);
		alpha = 0;
		Delta.tween(this).prop("alpha", 1, 2).ease(Elastic.easeIn).onComplete(doneInitializing);
		trace("Entering initial state");
	}
	
	function doneInitializing() 
	{
		initialized = true;
	}

	public function update(g: Game, dt: Float): IGameState
	{
		if (initialized) 
		{
			var gamePlayState = new GamePlayState();
			g.setState(gamePlayState);
			return gamePlayState;
		}
		return this;
	}

	public function render(g: Game): Void
	{

	}

	public function exit(g: Game): Void
	{
		trace("Exiting initial state");
		g.removeChild(this);
	}
}
