package coldboot;
import coldboot.Game;
import coldboot.IGameState;
import coldboot.UpdateInfo;

interface IState
{
	function enter(g: Game, ?args:Dynamic): Void;
	function update(info:UpdateInfo): IState;
	function exit(g: Game): Void;
}