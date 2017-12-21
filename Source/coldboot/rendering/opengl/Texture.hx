package coldboot.rendering.opengl;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
class Texture{
    GLTexture _id;
    public function new(filePath:String, repeat:Bool = true){
        _id = TextureUtils.createTextureFromBitmap(filePath, repeat);
    }
}