package coldBoot.ai;

import glm.Vec2;
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

interface EnemyController {
	public var position = new Vec2(0,0);
	public function move(dir:Vec2):Void;
}

class EnemyAI {
	var pathMemory:PathMemory;
	var controller:EnemyController;
	var map:PathFinding.GameMap;
	var enemyMap:PathFinding.GameMap;
	
	var currentPathStack:GenericStack<Int> = new GenericStack<Int>();
	var currentPath:Array<Vec2> = new Array<Vec2>();
	var currentTarget: Vec2;
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

		enemyMap = new PathFinding.GameMap(map.cols, map.rows, map.cellSize, function(idx) { 
			return knownWalkablePlaces[idx];
		});

		currentTarget = controller.position;
	}

	public function performAction() {
		if(currentPath.length == 0)
		{
			var currentIdx = map.toNodeIdx(controller.position);
			var forwardIdx = currentIdx + map.cols;
			var backwardIdx = currentIdx - map.cols;
			var leftIdx = currentIdx - 1;
			var rightIdx = currentIdx + 1;

			if(forwardIdx >= 0 && map.isWalkableByIdx(forwardIdx) && !knownWalkablePlaces[forwardIdx])
			{
				currentPathStack.add(forwardIdx);
				knownWalkablePlaces[forwardIdx] = true;
			}

			if(backwardIdx >= 0 && map.isWalkableByIdx(backwardIdx) && !knownWalkablePlaces[backwardIdx])
			{
				currentPathStack.add(backwardIdx);
				knownWalkablePlaces[backwardIdx] = true;
			}

			if(leftIdx >= 0 && map.isWalkableByIdx(leftIdx) && !knownWalkablePlaces[leftIdx])
			{
				currentPathStack.add(leftIdx);
				knownWalkablePlaces[leftIdx] = true;
			}

			if(rightIdx >= 0 && map.isWalkableByIdx(rightIdx) && !knownWalkablePlaces[rightIdx])
			{
				currentPathStack.add(rightIdx);
				knownWalkablePlaces[rightIdx] = true;
			}

			var nextPath = currentPathStack.pop();
			if(nextPath != null) {
				currentPath = new PathFinding().ShortestPath(currentIdx, nextPath, this.enemyMap);
				currentPath.reverse();
			}
		}

		trace(currentPath);

		if(Vec2.distance(currentTarget, controller.position) < 2 && currentPath.length > 0) {
			currentTarget = currentPath.pop();
		}

		var dir = new Vec2(0,0);
		Vec2.normalize(currentTarget - controller.position, dir);
		controller.move(dir);
	}
}