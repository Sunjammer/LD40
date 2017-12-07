package coldboot.states;

/**
 * ...
 * @author Andreas Kennedy
 */
class PlayerInfo {

  public var health:Float;
  public var power:Float;
  var initHealth:Float;
  var initPower:Float;
  public function new(health:Float, power:Float) {
    this.health = initHealth = health;
    this.power = initPower = power;
  }
  public function reset(){
    health = initHealth;
    power = initPower;
  }
  
}