package coldBoot.ai;

import lime.math.Vector2;
import haxe.ds.GenericStack;

interface Goal {
}

interface AtomicGoal extends Goal {

}

interface CompositeGoal extends Goal {

}

class PathMemory {
	var nodesVisited:Map<Int,Bool>;

	public function new() {
	}

	public function hasBeenHere(nodeIdx:Int) {
		return nodesVisited.exists(nodeIdx);
	}
}

class EnemyController {
	public var position = new Vector2(0,0);
	var moveSpeed:Float = 10;

	public function move(dir:Vector2) {
		 position.x += dir.x * moveSpeed;
		 position.y += dir.y * moveSpeed;
	}
}

class Enemy {
	var pathMemory:PathMemory;
	var controller:EnemyController;
	var map:PathFinding.GameMap;
	var enemyMap:PathFinding.GameMap;
	
	var currentPathStack:GenericStack<Int> = new GenericStack<Int>();
	var currentPath:Array<Vector2>;
	var knownWalkablePlaces:Array<Bool>;

	public function new(map:PathFinding.GameMap, controller:EnemyController) {
		this.controller = controller;
		pathMemory = new PathMemory();
		this.map = map;
		knownWalkablePlaces = new Array<Bool>();
		for(i in 0...map.cols*map.rows) {
			knownWalkablePlaces[i] = false;
		}
		knownWalkablePlaces[map.toNodeIdx(controller.position)] = true; // Add spawn point

		enemyMap = new PathFinding.GameMap(map.cols, map.rows, map.cellSize, knownWalkablePlaces);
	}

	public function performAction() {
		if(currentPath.length == 0)
		{
			var currentIdx = map.toNodeIdx(controller.position);
			var forwardIdx = map.toNodeIdx(controller.position) + map.cols;
			var backwardIdx = map.toNodeIdx(controller.position) - map.cols;
			var leftIdx = map.toNodeIdx(controller.position) - 1;
			var rightIdx = map.toNodeIdx(controller.position) + 1;

			if(map.isWalkableIdx(forwardIdx) && !knownWalkablePlaces[forwardIdx])
			{
				currentPathStack.add(forwardIdx);
				knownWalkablePlaces[forwardIdx] = true;
			}

			if(map.isWalkableIdx(backwardIdx) && !knownWalkablePlaces[backwardIdx])
			{
				currentPathStack.add(backwardIdx);
				knownWalkablePlaces[backwardIdx] = true;
			}

			if(map.isWalkableIdx(leftIdx) && !knownWalkablePlaces[leftIdx])
			{
				currentPathStack.add(leftIdx);
				knownWalkablePlaces[leftIdx] = true;
			}

			if(map.isWalkableIdx(rightIdx) && !knownWalkablePlaces[rightIdx])
			{
				currentPathStack.add(rightIdx);
				knownWalkablePlaces[rightIdx] = true;
			}

			var nextPath = currentPathStack.pop();
			if(nextPath != null) {
				currentPath = new PathFinding().ShortestPath(currentIdx, cast(nextPath, Int), this.enemyMap);
				currentPath.reverse();
			}
		}

		if(currentPath.length == 0)
			neko.Lib.print("I'm stuck!");

		var supposedToBeHere = currentPath[currentPath.length - 1];
		if(Vector2.distance(supposedToBeHere, controller.position) < 10) {
			currentPath.pop();
		}

		var dir = supposedToBeHere.subtract(controller.position);
		dir.normalize(1);
		controller.move(dir);
	}
}