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

    # puts scan(:forward)
    # puts scan(:backward)

    random_direction = (rand(2) == 0 ? :forward : :backward)
    other_direction  = (random_direction == :forward ? :backward : :forward)

    if target_in_sight?(random_direction)
      shoot!(random_direction)
    elsif target_in_sight?(other_direction)
        shoot!(other_direction)
    elsif taking_damage?
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

  def look(orientation=self.direction)
    warrior.look(orientation)
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

  def shoot!(orientation=self.direction)
    warrior.shoot!(orientation)
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

  def target_in_sight?(orientation=self.direction)
    look(orientation).each do |cell|
      if cell.captive? || cell.wall?
        return false
      elsif !cell.empty?
        return true
      end
    end

    false
  end

  def walk!
    warrior.walk!(direction)
  end

  def scan(orientation)
    cells = warrior.look(orientation)
    summary = cells.collect {|cell|
      if cell.captive?
        'C'
      elsif cell.empty?
        '_'
      elsif cell.wall?
        '|'
      else
        # extra_methods = cell.methods - Object.new.methods
        # question_methods = extra_methods.grep /\?/
        # question_methods.inject({}) {|memo, msg|
        #   memo[msg] = cell.send(msg)
        #   memo
        # }
        'X'
      end
    }
    "SCAN #{orientation}:\t#{summary}"
  end

end
