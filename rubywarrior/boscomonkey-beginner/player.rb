class Player
  attr_reader :direction, :warrior

  def initialize(initial_health=20)
    @direction     = :forward
    @latest_health = initial_health
    @max_health    = initial_health
    @warrior       = nil
  end

  def play_turn(avatar)
    @warrior = avatar

    if taking_damage?
      if feel_captive?
        rescue_captive!
      elsif feel_empty?
        walk!
      else
        attack!
      end
    elsif feel_captive?
      rescue_captive!
    elsif feel_empty?
      if should_rest?
        rest!
      else
        walk!
      end
    else
      attack!
    end

    record_health(warrior)
  end

  def attack!
    warrior.attack!(direction)
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

  def record_health(warrior)
    @latest_health = warrior.health
  end

  def rescue_captive!
    warrior.rescue!(direction)
  end

  def rest!
    warrior.rest!
  end

  def reverse_direction
    @direction = (:forward == @direction ? :backward : :forward)
  end

  def should_rest?
    warrior.health < @max_health
  end

  def taking_damage?
    warrior.health < @latest_health
  end

  def walk!
    warrior.walk!(direction)
  end

end
