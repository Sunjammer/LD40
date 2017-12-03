package coldBoot;
import coldBoot.IState;
import coldBoot.RenderInfo;

interface IGameState extends IState
{
	function render(info:RenderInfo): Void;
	function addChildEntity(e: Entity): Void;
	function removeChildEntity(e: Entity): Void;
}