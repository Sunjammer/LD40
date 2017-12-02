import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import glm.Vec2;

enum Direction {
    North;
    East;
    South;
    West;
}

class DirectionExtensions {
public static function toVec2(direction: Direction):Vec2 {
        switch (direction) {
            case Direction.North: return new Vec2(0, -1);
            case Direction.East: return new Vec2(1, 0);
            case Direction.South: return new Vec2(0, 1);
            case Direction.West: return new Vec2(-1, 0);
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

interface Tile {
    public function isOpen(): Bool;
    public function isPathOpen(direction: Direction): Bool;
}

interface TileMap {
    public function getTile(position: Vec2): Tile;
    public function getBitmap(): Bitmap;
    public function getWidth(): UInt;
    public function getHeight(): UInt;
}

class MapGenerator {
    public static function recursiveBacktracking(randomSeed: Int, startPoint: Vec2, width: UInt, height: UInt): TileMap {
        return RecursiveBacktracking.generate(randomSeed, startPoint, width, height);
    }

    public static function kurskal(randomSeed: Int, width: UInt, height: UInt) {
        return Kurskal.generate(randomSeed, width, height);
    }
}
