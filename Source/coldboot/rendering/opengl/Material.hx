package coldboot.rendering.opengl;

class Material{
    public var textures:Array<Texture>;
    public var shader:Shader;
    public function new(shader:Shader, textures:Array<Texture>){
        this.textures = textures;
        this.shader = shader;
    }
}