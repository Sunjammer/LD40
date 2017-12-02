package coldBoot.states;
import coldBoot.Game;
import openfl.display.Shape;
import tween.Delta;
import tween.easing.Elastic;

class InitialState extends Shape implements IGameState
{
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
		Delta.tween(this).prop("alpha", 1, 2).ease(Elastic.easeIn);
		trace("Entering initial state");
	}

	public function update(g: Game, dt: Float): IGameState
	{
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
