class Player
  def initialize
    @last_health = 0
  end

  def play_turn(warrior)
    if taking_damage?(warrior)
      if warrior.feel.captive?
        warrior.rescue!
      elsif warrior.feel.empty?
        warrior.walk!
      else
        warrior.attack!
      end
    elsif warrior.feel.captive?
      warrior.rescue!
    elsif warrior.feel.empty?
      if should_rest(warrior)
        warrior.rest!
      else
        warrior.walk!
      end
    else
      warrior.attack!
    end

    record_health(warrior)
  end

  def record_health(warrior)
    @last_health = warrior.health
  end

  def should_rest(warrior)
    warrior.health < 18
  end

  def taking_damage?(warrior)
    warrior.health < @last_health
  end
end
