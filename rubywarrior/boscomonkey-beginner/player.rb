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

=begin

if enemy_immediately_in_direction
  attack!(direction)

if enemy_in_arrow_range_on_both_sides
  if last_attack_direction
    reverse_last_attack_direction
  else
    randomly_choose_attack_direction
  end
  shoot!(last_attack_direction)
else
  cancel_last_attack_direction

if captive_immediately_in_direction
  rescue!(direction)

if feel_wall?
  reverse_direction!

if feel_captive?
  rescue!

if empty?
  walk!

=end
  def play_turn(avatar)
    remember_current_warrior(avatar)

    # puts "#{scan(:backward).reverse}\tMYSELF\t#{scan(:forward)}"

    random_direction = (rand(2) == 0 ? :forward : :backward)

    Rules.new.
      add(:target_in_sight_both_direction,
          ->(r) { target_in_sight?(:forward) && target_in_sight?(:backward) },
          ->(r) {
            if @alpha_direction.nil?
              @alpha_direction = :backward
              @alpha_shot_count = 0
              @beta_shot_count = 0
            end 
          },
          ->(r) {
            if @alpha_direction
              @alpha_direction = @alpha_shot_count = @beta_shot_count = nil
            end }
          ).
      add(:shoot_alpha_or_beta_3_times_consecutively,
          ->(r) { !@alpha_direction.nil? },
          ->(r) {
            def shoot_alpha!
              shoot!(@alpha_direction)
              @alpha_shot_count += 1
            end

            def shoot_beta!
              shoot!(opposite_of @alpha_direction)
              @beta_shot_count += 1
            end

            if @alpha_shot_count == @beta_shot_count
              shoot_alpha!
            elsif @alpha_shot_count > @beta_shot_count
              if @alpha_shot_count%3 == 0
                shoot_beta!
              else
                shoot_alpha!
              end
            else # @alpha_shot_count < @beta_shot_count
              if @beta_shot_count%3 == 0
                shoot_alpha!
              else
                shoot_beta!
              end
            end

            r.stop! }
          ).
      add(:target_in_sight_random_direction,
          ->(r) { target_in_sight?(random_direction) },
          ->(r) {
            shoot!(random_direction)
            r.stop! }
          ).
      add(:target_in_sight_other_direction,
          ->(r) { target_in_sight?(opposite_of random_direction) },
          ->(r) {
            shoot!(opposite_of random_direction)
            r.stop! }
          ).
      add(:captive_in_sight_random_direction,
          ->(r) { captive_in_sight?(random_direction) },
          ->(r) { @direction = random_direction }
          ).
      add(:captive_in_sight_other_direction,
          ->(r) { captive_in_sight?(opposite_of random_direction) },
          ->(r) { @direction = opposite_of random_direction }
          ).
      add(:resting_or_should_rest,
          ->(r) { resting? || should_rest? },
          ->(r) {
            rest!
            r.stop! }
          ).
      add(:attack_if_enemy,
          ->(r) { feel_enemy? },
          ->(r) {
            attack!
            r.stop! }
          ).
      add(:pivot_if_wall,
          ->(r) { feel_wall? },
          ->(r) {
            reverse_direction!
            r.stop! }
          ).
      add(:rescue_if_captive,
          ->(r) { feel_captive? },
          ->(r) {
            rescue_captive!
            r.stop! }
          ).
      add(:walk_if_empty,
          ->(r) { feel_empty? },
          ->(r) {
            walk!
            r.stop! }
          ).
      run

    remember_health
  end

  def attack!
    warrior.attack!(direction)
  end

  def cancel_retreat
    @on_retreat = false
    @direction = :forward
  end

  def captive_in_sight?(orientation=self.direction)
    look(orientation).each do |cell|
      if cell.captive?
        return true
      elsif cell.wall? || cell.enemy?
        return false
      elsif cell.empty?
        # do nothing and loop again
      end
    end

    false
  end

  def feel_captive?
    warrior.feel(direction).captive?
  end

  def feel_empty?
    warrior.feel(direction).empty?
  end

  def feel_enemy?
    warrior.feel(direction).enemy?
  end

  def feel_wall?
    warrior.feel(direction).wall?
  end

  def look(orientation=self.direction)
    warrior.look(orientation)
  end

  def opposite_of(dir)
    :forward == dir ? :backward : :forward
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
    @on_rest = (warrior.health < @max_health/2)
  end

  def resting?
    @on_rest
  end

  def retreating?
    @on_retreat
  end

  def reverse_direction!
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
    cells_to_array(cells)
  end

  def cells_to_array(cells)
    cells.inject([]) {|memo, cell|
      if cell.captive?
        memo.push 'C'
      elsif cell.empty?
        memo.push '_'
      elsif cell.wall?
        memo.push '|'
        return memo
      else
        extra_methods = cell.methods - Object.new.methods
        question_methods = extra_methods.grep /\?/
        enemy = question_methods.inject([]) {|arry, msg|
          arry.push(msg) if cell.send(msg)
          arry
        }
        memo.push(enemy.join)
      end
    }
  end
end


class Rules
  def initialize
    @rules = []
    @exit_run = false
  end

  def add(name, if_proc, then_proc, else_proc=nil)
    raise "'name' cannot be nil or empty" if (name.nil? || name.empty?)

    rule_body = {name: name, if: if_proc, then: then_proc, else: else_proc}
    @rules.push rule_body

    self	# for chaining
  end

  def log_rule(success, name)
    puts "RULE:\t#{success ? '+' : '-'}\t#{name}" if success
  end

  def run
    @exit_run = false

    @rules.each do |rule|
      if rule[:if].call(self)
        rule[:then].call(self)

        log_rule(true, rule[:name])
      else
        if rule[:else]
          rule[:else].call(self)
        end

        log_rule(false, rule[:name])
      end

      break if @exit_run
    end
  end

  def stop!
    @exit_run = true
  end
end
