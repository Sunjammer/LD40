package coldBoot.map;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;
import coldBoot.map.MapGenerator.Direction;
import coldBoot.map.MapGenerator.DirectionExtensions;
import coldBoot.map.MapGenerator.Tile;
import coldBoot.map.MapGenerator.TileMap;

class Node implements Tile {

    public var north:Bool;
    public var east:Bool;
    public var south:Bool;
    public var west:Bool;
    public var position:Vec2;

    public function new(position: Vec2) {
        north = false;
        east = false;
        south = false;
        west = false;
        this.position = position;
    }

    public function isOpen(): Bool {
        return north || east || south || west;
    }
    
    public function isPathOpen(direction: Direction): Bool {
        switch (direction) {
            case Direction.North: return north;
            case Direction.East: return east;
            case Direction.South: return south;
            case Direction.West: return west;
        }
    }

    public function setPathOpen(direction: Direction) {
        switch (direction) {
            case Direction.North: north = true;
            case Direction.East: east = true;
            case Direction.South: south = true;
            case Direction.West: west = true;
        }
    }

    public function getSiblings(): Array<Vec2> {
        var siblings = new Array<Vec2>();
        if (north) siblings.push(position + DirectionExtensions.toVec2(Direction.North));
        if (east) siblings.push(position + DirectionExtensions.toVec2(Direction.East));
        if (south) siblings.push(position + DirectionExtensions.toVec2(Direction.South));
        if (west) siblings.push(position + DirectionExtensions.toVec2(Direction.West));
        return siblings;
    }
}

class Tree {
    public var parent:Tree;

    public function new() {
        this.parent = null;
    }

    public function getRoot(): Tree {
        return parent != null ? parent.getRoot() : this;
    }

    public function isConnected(other: Tree): Bool {
        return getRoot() == other.getRoot();
    }

    public function connect(other: Tree) {
        other.getRoot().parent = this;
    }
}

class Edge {
    public var coord: Vec2;
    public var dir: Direction;

    public function new(coord: Vec2, dir: Direction) {
        this.coord = coord;
        this.dir = dir;
    }

    public static function generateEdges(width: UInt, height: UInt): Array<Edge> {
        var edges = new Array<Edge>();
        for (y in 1...height) {
            for (x in 1...width) {
                edges.push(new Edge(new Vec2(x, y), Direction.North));
                edges.push(new Edge(new Vec2(x, y), Direction.West));
            }
        }
        return edges;
    } 
}

class Kurskal implements TileMap {

    public var nodes: Array<Node>;
    public var width: UInt;
    public var height: UInt;

    public function getTile(position: Vec2): Tile {
        return nodes[offset(position)];
    }

    public function getBitmap(): Bitmap {
        var bitmapData = new BitmapData(width * 3, height * 3, false, 0xff000000);
        for (n in nodes) {
            var p1 = new Point(n.position.x * 3 + 1, n.position.y * 3 + 1);
            for (s in n.getSiblings()) {
                var p2 = new Point(s.x * 3 + 1, s.y * 3 + 1);
                drawLine(p1, p2, bitmapData);
            }
        }
        return new Bitmap(bitmapData);
    }
    
    private function drawLine(p1: Point, p2: Point, bitmapData: BitmapData) {
        var len = Math.ceil(Point.distance(p1, p2));
        for (i in 0...len) {
            var p = Point.interpolate(p1, p2, i / len);
            var x = Math.floor(Math.max(Math.min(p.x, width * 3 - 1), 0));
            var y = Math.floor(Math.max(Math.min(p.y, height * 3 - 1), 0));
            bitmapData.setPixel(x, y, 0xffffffff);
        }
    }

    public function getWidth(): UInt {
        return width;
    }

    public function getHeight(): UInt {
        return height;
    }

    public function getMap(): Array<Int> {
        var size = (width * 3) * (height * 3);
        var map = [for (i in 0...size) 1];
        for (n in nodes) {
            var p1 = new Point(n.position.x * 3 + 1, n.position.y * 3 + 1);
            for (s in n.getSiblings()) {
                var p2 = new Point(s.x * 3 + 1, s.y * 3 + 1);
                plotLine(p1, p2, map);
            }
        }
        return map;
    }

    private function plotLine(p1: Point, p2: Point, map: Array<Int>) {
        var len = Math.ceil(Point.distance(p1, p2));
        for (i in 0...len) {
            var p = Point.interpolate(p1, p2, i / len);
            var x = Math.floor(Math.max(Math.min(p.x, width * 3 - 1), 0));
            var y = Math.floor(Math.max(Math.min(p.y, height * 3 - 1), 0));
            var offset = (y * width * 3) + x;
            map[offset] = 0;
        }
    }

    private function offset(coord: Vec2): UInt {
        var x = Math.floor(coord.x);
        var y = Math.floor(coord.y);
        return y * height + x;
    }

    private function new(randomSeed: Int, width: UInt, height: UInt) {
        this.width = width;
        this.height = height;
        var edges = Randomize.shuffle(Edge.generateEdges(width, height));
        var tileCount = width * height;
        nodes = new Array<Node>();
        for (y in 0...height) {
            for (x in 0...width) {
                nodes.push(new Node(new Vec2(x, y)));
            }
        }
        var sets = [for(i in 0...tileCount) new Tree()];

        while (edges.length > 0) {
            var edge = edges.pop();   
            var newCoord = edge.coord + DirectionExtensions.toVec2(edge.dir);
            var offset1 = offset(edge.coord);
            var offset2 = offset(newCoord);
            var set1 = sets[offset1];
            var set2 = sets[offset2];

            if (!set1.isConnected(set2)) {
                set1.connect(set2);

                var tile1 = nodes[offset1];
                var tile2 = nodes[offset2];

                tile1.setPathOpen(edge.dir);
                tile2.setPathOpen(DirectionExtensions.getOppositeDirection(edge.dir));
            }
        }
    }

    public static function generate(randomSeed: Int, width: UInt, height: UInt): TileMap {
        return new Kurskal(randomSeed, width, height);
    }
}