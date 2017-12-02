import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;
import MapGenerator.Direction;
import MapGenerator.Tile;
import MapGenerator.TileMap;
import neko.Random;

private class DirectionHelper {
    public static function toPoint(direction: Direction):Point {
        switch (direction) {
            case Direction.North: return new Point(0, -1);
            case Direction.East: return new Point(1, 0);
            case Direction.South: return new Point(0, 1);
            case Direction.West: return new Point(-1, 0);
        }
    }
    public static function getOppositeDirection(direction: Direction): Direction {
        switch (direction) {
            case Direction.North: return Direction.South;
            case Direction.East: return Direction.West;
            case Direction.South: return Direction.North;
            case Direction.West: return Direction.East;
        }
    }
}

private class RBTile implements MapGenerator.Tile {
    public var North:Bool;
    public var East:Bool;
    public var South:Bool;
    public var West:Bool;
    public var Visited: Bool;

    public function new() {
        North = false;
        East = false;
        South = false;
        West = false;
        Visited = false;
    }

    /*public function carvePassage(direction: Direction) {
        if (direction == Direction.North || direction == Direction.South) {
            North = South = true;
        } else {
            East = West = true;
        }
    }*/

    public function isOpen(): Bool {
        return North || East || South || West;
    }

    public function isPathOpen(direction: Direction): Bool {
        switch (direction) {
            case Direction.North: return North;
            case Direction.East: return East;
            case Direction.South: return South;
            case Direction.West: return West;
        }
    }

    public function setPathOpen(direction: Direction) {
        switch (direction) {
            case Direction.North: North = true;
            case Direction.East: East = true;
            case Direction.South: South = true;
            case Direction.West: West = true;
        }
    }
}

private class RBTileMap implements MapGenerator.TileMap {
    private var tiles: Array<RBTile>;
    private var width: UInt;
    private var height: UInt;
    public var node: Node;

    public function new(width: UInt, height: UInt) {
        this.width = width;
        this.height = height;
        var tileCount = width * height;
        tiles = [for (i in 0...tileCount) new RBTile()];
    }

    public function getBitmapData():BitmapData {
        var bitmapData = new BitmapData(width * 3, height * 3, false, 0xff000000);
        paintBitmapData(node, bitmapData);
        return bitmapData;
    }

    private function paintBitmapData(node: Node, bitmapData: BitmapData) {
        for (child in node.children) {
            drawLine(new Point(node.position.x * 3 + 1, node.position.y * 3 + 1), new Point(child.position.x * 3 + 1, child.position.y * 3 + 1), bitmapData);
            paintBitmapData(child, bitmapData);
        }
    }

    private function drawLine(p1: Point, p2: Point, bitmapData: BitmapData) {
        var len = Math.ceil(Point.distance(p1, p2));
        for (i in 0...len) {
            var p = Point.interpolate(p1, p2, i / len);
            var x = cast(Math.max(Math.min(p.x, width * 3 - 1), 0), Int);
            var y = cast(Math.max(Math.min(p.y, height * 3 - 1), 0), Int);
            bitmapData.setPixel(x, y, 0xffffffff);
        }
    }

    public function getTile(point: Vec2): RBTile {
        if (point.x >= 0 && point.x < width &&
            point.y >= 0 && point.y < height) {
            var offset = cast(point.y, UInt) * width + cast(point.x, UInt);
            return tiles[offset];
        } else {
            return null;
        }
    }

    public function getTilePoint(point: Point): RBTile {
        if (point.x >= 0 && point.x < width &&
            point.y >= 0 && point.y < height) {
            var offset = cast(point.y, UInt) * width + cast(point.x, UInt);
            return tiles[offset];
        } else {
            return null;
        }
    }

    public function getBitmap(): Bitmap {
        return new Bitmap(getBitmapData());
    }

    public function getWidth(): UInt {
        return width;
    }

    public function getHeight(): UInt {
        return height;
    }
}

private class Node {
    public var parent: Node;
    public var position: Point;
    public var children: Array<Node>;

    public function new(position: Point, parent: Node) {
        this.position = position;
        this.parent = parent;
        this.children = new Array<Node>();
    }
}

class RecursiveBacktracking {

    public static function generate(randomSeed: Int, startPoint: Vec2, width: UInt, height: UInt):RBTileMap {
        var sp = new Point(startPoint.x, startPoint.y);
        var tileMap = new RBTileMap(width, height);
        var node = new Node(sp, null);
        var startTile = tileMap.getTilePoint(sp);
        carvePassageFrom(randomSeed, node, startTile, sp, tileMap);
        tileMap.node = node;
        return tileMap;
    }

    private static function carvePassageFrom(randomSeed:Int, node: Node, origin: RBTile, point: Point, tileMap: RBTileMap) {
        var directions = Rand.shuffle(randomSeed, [Direction.North, Direction.East, Direction.South, Direction.West]);
        for (d in directions) {
            var newPoint = point.add(DirectionHelper.toPoint(d));
            var tile = tileMap.getTilePoint(newPoint);
            if (tile == null || tile.Visited)
                continue;
            tile.Visited = true;
            origin.setPathOpen(d);
            tile.setPathOpen(DirectionHelper.getOppositeDirection(d));
            var n = new Node(newPoint, node);
            carvePassageFrom(randomSeed, n, tile, newPoint, tileMap);
            node.children.push(n);
        }   
    }
}

private class Rand {
    public static function shuffle<T>(randomSeed: Int, arr:Array<T>):Array<T> {
		if (arr!=null) {
			for (i in 0...arr.length) {
				var j = int(randomSeed, 0, arr.length - 1);
				var a = arr[i];
				var b = arr[j];
				arr[i] = b;
				arr[j] = a;
			}
		}
		return arr;
    }

    public static inline function int(randomSeed: Int, from:Int, to:Int):Int {
        var r = new Random();
        r.setSeed(randomSeed);
		return from + Math.floor(((to - from + 1) * r.float()));
    }
}