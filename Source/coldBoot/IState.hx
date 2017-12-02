package coldBoot;
import coldBoot.Game;
import coldBoot.IGameState;
import coldBoot.UpdateInfo;

interface IState
{
	function enter(g: Game): Void;
	function update(info:UpdateInfo): IGameState;
	function exit(g: Game): Void;
}