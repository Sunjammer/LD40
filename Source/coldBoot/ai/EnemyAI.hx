package coldBoot.ai;

import glm.Vec2;
import haxe.ds.GenericStack;
import Random;

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
		if(currentPath.length == 0 && nearTarget())
		{
			controller.position = currentTarget;
			var currentIdx = map.toNodeIdx(controller.position);
			var currentPos = map.toCoordinate(currentIdx);

			var newStackItems = new Array<Int>();

			if(currentPos.y + 1 < map.rows)
			{
				var forwardIdx = map.posToNodeIdx(currentPos.x, currentPos.y + 1);
				if(map.isWalkableByIdx(forwardIdx) && !knownWalkablePlaces[forwardIdx])
				{
					newStackItems.push(forwardIdx);
					knownWalkablePlaces[forwardIdx] = true;
				}
			}

			if(currentPos.y - 1 >= 0)
			{
				var backwardIdx = map.posToNodeIdx(currentPos.x, currentPos.y - 1);
				if(map.isWalkableByIdx(backwardIdx) && !knownWalkablePlaces[backwardIdx])
				{
					newStackItems.push(backwardIdx);
					knownWalkablePlaces[backwardIdx] = true;
				}
			}

			if(currentPos.x + 1 < map.cols)
			{
				var rightIdx = map.posToNodeIdx(currentPos.x + 1, currentPos.y);
				if(map.isWalkableByIdx(rightIdx) && !knownWalkablePlaces[rightIdx])
				{
					newStackItems.push(rightIdx);
					knownWalkablePlaces[rightIdx] = true;
				}
			}

			if(currentPos.x - 1 >= 0)
			{
				var leftIdx = map.posToNodeIdx(currentPos.x - 1, currentPos.y);
				if(map.isWalkableByIdx(leftIdx) && !knownWalkablePlaces[leftIdx])
				{
					newStackItems.push(leftIdx);
					knownWalkablePlaces[leftIdx] = true;
				}
			}

			for(i in Random.shuffle(newStackItems)) {
				currentPathStack.add(i);
			}

			var nextPath = currentPathStack.pop();
			if(nextPath != null) {
				currentPath = new PathFinding().ShortestPath(currentIdx, nextPath, this.enemyMap);
				currentPath.reverse();
			}
		}

		if(nearTarget()) {
			controller.position = currentTarget;
			if(currentPath.length > 0) {
				currentTarget = currentPath.pop();
			}
		}
		
		var dir = new Vec2(0,0);
		Vec2.normalize(currentTarget - controller.position, dir);
		trace(dir);
		controller.move(dir);
	}

	function nearTarget() {
		return Vec2.distance(currentTarget, controller.position) < 2;
	}
}