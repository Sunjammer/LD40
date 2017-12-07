package coldboot.states;
import coldboot.Entity;
import coldboot.Game;
import coldboot.UpdateInfo;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import tween.easing.Elastic;
import tween.easing.Quad;

class InitialState extends Sprite implements IGameState
{
	var initialized:Bool;
	public function new()
	{
		super();
	}

	public function enter(g: Game, ?args:Dynamic): Void
	{
		g.stateSpriteContainer.addChild(this);
		
		var imgs:Array<String> = cast args;
		
		var cnt = 0;
		for (i in imgs){
			var img = addChild(new Bitmap(Assets.getBitmapData(i)));
			img.alpha = 0;
			
			Delta.tween(img)
				.wait(cnt * 6)
				.propMultiple({x: -(img.width - g.viewportSize.width), y: -(img.height - g.viewportSize.height)}, 6)
				.ease(Quad.easeInOut);
			
			Delta.tween(img)
				.wait(cnt*6)
				.prop("alpha", 1, 2)
				.wait(3)
				.prop("alpha", 0, 2);
			cnt++;
		}
		Delta.delayCall(doneInitializing, cnt * 6 + 1);
		trace("Entering initial state");
	}
	
	function doneInitializing() 
	{
		trace("Init");
		initialized = true;
	}

	public function update(info:UpdateInfo): IGameState
	{
		if (info.game.audio.pollStatus() == Ready) 
		{
			//return info.game.setState(new GamePlayState());
		}
		return this;
	}

	public function render(info:RenderInfo): Void
	{

	}

	public function exit(g:Game): Void
	{
		trace("Exiting initial state");
		removeChildren();
		g.stateSpriteContainer.removeChild(this);
	}
	
	
	/* INTERFACE coldboot.IGameState */
	
	public function getRootEntity():Entity 
	{
		return null;
	}
	
	
}
