class Player
  def play_turn(warrior)
    if warrior.feel.empty?
      if should_rest(warrior)
        warrior.rest!
      else
        warrior.walk!
      end
    else
      warrior.attack!
    end
  end

  def should_rest(warrior)
    warrior.health < 18
  end
end
