package coldboot.rendering.opengl;
import glm.Vec2;
class RenderBuffer{
    var dims:Vec2;
    public function new(dims:Vec2){
        this.dims = dims;
        rebuild(dims);
    }

    public function dispose(){
        
    }

    public function rebuild(dims:Vec2){
        if(dims.equals(this.dims)) return;
        this.dims = dims;
    }
}

class RenderBufferPool{
    static var pool:List<RenderBuffer>;
    static var used:List<RenderBuffer>;
    static var initialized:Bool = false;

    static function initialize(){
        pool = new List<RenderBuffer>();
        used = new List<RenderBuffer>();
        initialized = true;
    }
    public static function lock(dims:Vec2, retain:Bool):RenderBuffer{
        if(!initialized) initialize();
        if(pool.length!=0){
            var b = pool.first();
            pool.remove(b);
            used.add(b);
            b.rebuild(dims);
            return b;
        }
        var newBuffer = new RenderBuffer(dims);
        pool.add(newBuffer);
        return lock(dims, retain);
    }


    public static function clear(){
        for(b in used){
            b.dispose();
            used.remove(b);
        }
        for(p in pool){
            p.dispose();
            pool.remove(p);
        }
    }

    public static function release(buffer:RenderBuffer){
        if(used.)
    }
    
}