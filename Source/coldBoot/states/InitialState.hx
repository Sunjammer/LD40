package coldBoot.states;
import coldBoot.Game;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import tween.Delta;

class InitialState extends Sprite implements IGameState
{
	var initialized:Bool;
	public function new()
	{
		super();
		graphics.beginFill(0xff0000);
		graphics.drawCircle(100, 100, 100);
    
    var bitmapData = Assets.getBitmapData ("assets/c1.jpg");
    addChild(new Bitmap(bitmapData));
    
    var tf = new TextField();
    var format = new TextFormat(null, 32);
 
    tf.text = "FUCK ALL YALL";
    tf.autoSize = TextFieldAutoSize.LEFT;
    tf.setTextFormat(format);
    addChild(tf);
	}

	public function enter(g: Game): Void
	{
		g.addChild(this);
		alpha = 0;
		Delta.tween(this).prop("alpha", 1, 2).onComplete(doneInitializing);
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
