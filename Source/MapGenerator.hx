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
}
