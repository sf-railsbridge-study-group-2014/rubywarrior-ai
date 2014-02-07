class Player
  attr_reader :direction, :warrior

  def initialize(initial_health=20)
    @direction     = :forward
    @latest_health = initial_health
    @max_health    = initial_health
    @on_rest       = false
    @on_retreat    = false
    @warrior       = nil
  end

  def play_turn(avatar)
    remember_current_warrior(avatar)

    if taking_damage?
      signal_retreat
      advance
    elsif resting? || should_rest?
      rest!
    else
      cancel_retreat if retreating?
      advance
    end

    remember_health
  end

  def advance
    if feel_captive?
      rescue_captive!
    elsif feel_empty?
      walk!
    elsif feel_wall?
      reverse_direction
    else
      attack!
    end
  end

  def attack!
    warrior.attack!(direction)
  end

  def cancel_retreat
    @on_retreat = false
    @direction = :forward
  end

  def feel_captive?
    warrior.feel(direction).captive?
  end

  def feel_empty?
    warrior.feel(direction).empty?
  end

  def feel_wall?
    warrior.feel(direction).wall?
  end

  def remember_current_warrior(avatar)
    @warrior = avatar
  end

  def remember_health
    @latest_health = warrior.health
  end

  def rescue_captive!
    warrior.rescue!(direction)
  end

  def rest!
    warrior.rest!
    @on_rest = (warrior.health < @max_health-2)
  end

  def resting?
    @on_rest
  end

  def retreating?
    @on_retreat
  end

  def reverse_direction
    warrior.pivot!(:backward)
  end

  def should_rest?
    warrior.health < @max_health/2
  end

  def signal_retreat
    @on_retreat = true
    @direction = :backward
  end

  def taking_damage?
    warrior.health < @latest_health && should_rest?
  end

  def walk!
    warrior.walk!(direction)
  end

end
