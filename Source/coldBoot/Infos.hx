package Source.coldBoot;
import coldBoot.Game;

/**
 * Info boxes 
 * @author Andreas Kennedy
 */

typedef DeltaTime = Float;

enum Infos {
  GameUpdate(game:Game, dt:DeltaTime);
}