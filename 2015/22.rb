require_relative 'util'

# --- Day 22: Wizard Simulator 20XX ---

# Little Henry Case decides that defeating bosses with swords and
# stuff is boring. Now he's playing the game with a wizard. Of course,
# he gets stuck on another boss and needs your help again.

# In this version, combat still proceeds with the player and the boss
# taking alternating turns. The player still goes first. Now, however,
# you don't get any equipment; instead, you must choose one of your
# spells to cast. The first character at or below 0 hit points loses.

# Since you're a wizard, you don't get to wear armor, and you can't
# attack normally. However, since you do magic damage, your opponent's
# armor is ignored, and so the boss effectively has zero armor as
# well. As before, if armor (from a spell, in this case) would reduce
# damage below 1, it becomes 1 instead - that is, the boss' attacks
# always deal at least 1 damage.

# On each of your turns, you must select one of your spells to
# cast. If you cannot afford to cast any spell, you lose. Spells cost
# mana; you start with 500 mana, but have no maximum limit. You must
# have enough mana to cast a spell, and its cost is immediately
# deducted when you cast it. Your spells are Magic Missile, Drain,
# Shield, Poison, and Recharge.

# - Magic Missile costs 53 mana. It instantly does 4 damage.
# - Drain costs 73 mana. It instantly does 2 damage and heals you for
#   2 hit points.
# - Shield costs 113 mana. It starts an effect that lasts for 6
#   turns. While it is active, your armor is increased by 7.
# - Poison costs 173 mana. It starts an effect that lasts for 6
#   turns. At the start of each turn while it is active, it deals the
#   boss 3 damage.
# - Recharge costs 229 mana. It starts an effect that lasts for 5
#   turns. At the start of each turn while it is active, it gives you
#   101 new mana.

# Effects all work the same way. Effects apply at the start of both
# the player's turns and the boss' turns. Effects are created with a
# timer (the number of turns they last); at the start of each turn,
# after they apply any effect they have, their timer is decreased by
# one. If this decreases the timer to zero, the effect ends. You
# cannot cast a spell that would start an effect which is already
# active. However, effects can be started on the same turn they end.

# For example, suppose the player has 10 hit points and 250 mana, and
# that the boss has 13 hit points and 8 damage:

#     -- Player turn --
#     - Player has 10 hit points, 0 armor, 250 mana
#     - Boss has 13 hit points
#     Player casts Poison.
#
#     -- Boss turn --
#     - Player has 10 hit points, 0 armor, 77 mana
#     - Boss has 13 hit points
#     Poison deals 3 damage; its timer is now 5.
#     Boss attacks for 8 damage.
#
#     -- Player turn --
#     - Player has 2 hit points, 0 armor, 77 mana
#     - Boss has 10 hit points
#     Poison deals 3 damage; its timer is now 4.
#     Player casts Magic Missile, dealing 4 damage.
#
#     -- Boss turn --
#     - Player has 2 hit points, 0 armor, 24 mana
#     - Boss has 3 hit points
#     Poison deals 3 damage. This kills the boss, and the player wins.

# Now, suppose the same initial conditions, except that the boss has
# 14 hit points instead:

#     -- Player turn --
#     - Player has 10 hit points, 0 armor, 250 mana
#     - Boss has 14 hit points
#     Player casts Recharge.
#
#     -- Boss turn --
#     - Player has 10 hit points, 0 armor, 21 mana
#     - Boss has 14 hit points
#     Recharge provides 101 mana; its timer is now 4.
#     Boss attacks for 8 damage!
#
#     -- Player turn --
#     - Player has 2 hit points, 0 armor, 122 mana
#     - Boss has 14 hit points
#     Recharge provides 101 mana; its timer is now 3.
#     Player casts Shield, increasing armor by 7.
#
#     -- Boss turn --
#     - Player has 2 hit points, 7 armor, 110 mana
#     - Boss has 14 hit points
#     Shield's timer is now 5.
#     Recharge provides 101 mana; its timer is now 2.
#     Boss attacks for 8 - 7 = 1 damage!
#
#     -- Player turn --
#     - Player has 1 hit point, 7 armor, 211 mana
#     - Boss has 14 hit points
#     Shield's timer is now 4.
#     Recharge provides 101 mana; its timer is now 1.
#     Player casts Drain, dealing 2 damage, and healing 2 hit points.
#
#     -- Boss turn --
#     - Player has 3 hit points, 7 armor, 239 mana
#     - Boss has 12 hit points
#     Shield's timer is now 3.
#     Recharge provides 101 mana; its timer is now 0.
#     Recharge wears off.
#     Boss attacks for 8 - 7 = 1 damage!
#
#     -- Player turn --
#     - Player has 2 hit points, 7 armor, 340 mana
#     - Boss has 12 hit points
#     Shield's timer is now 2.
#     Player casts Poison.
#
#     -- Boss turn --
#     - Player has 2 hit points, 7 armor, 167 mana
#     - Boss has 12 hit points
#     Shield's timer is now 1.
#     Poison deals 3 damage; its timer is now 5.
#     Boss attacks for 8 - 7 = 1 damage!
#
#     -- Player turn --
#     - Player has 1 hit point, 7 armor, 167 mana
#     - Boss has 9 hit points
#     Shield's timer is now 0.
#     Shield wears off, decreasing armor by 7.
#     Poison deals 3 damage; its timer is now 4.
#     Player casts Magic Missile, dealing 4 damage.
#
#     -- Boss turn --
#     - Player has 1 hit point, 0 armor, 114 mana
#     - Boss has 2 hit points
#     Poison deals 3 damage. This kills the boss, and the player wins.

# You start with 50 hit points and 500 mana points. The boss's actual
# stats are in your puzzle input. What is the least amount of mana you
# can spend and still win the fight? (Do not include mana recharge
# effects as "spending" negative mana.)

input = File.open('22.txt') { |f| f.read.scan(/\d+/).map(&:to_i) }

SPELLS = { magic_missile: 53,
           drain: 73,
           shield: 113,
           poison: 173,
           recharge: 229 }.freeze

class RPGSim
  def initialize(player, boss)
    @player = player.clone
    @boss = boss.clone
    @effects = Hash.new { |h, k| h[k] = 0 }
    @magic_armor = 0
  end

  def done?
    @player[:hp] <= 0 || @boss[:hp] <= 0
  end

  def allowed_spells
    SPELLS.select { |s, m| @player[:mana] >= m && @effects[s] <= 0 }.keys
  end

  def win_or_loss?
    return :loss if @player[:hp] <= 0
    return :win if @boss[:hp] <= 0
    :tie
  end

  def consume_mana(n)
    raise 'not enough mana' unless @player[:mana] >= n
    @player[:mana] -= n
  end

  def magic_missile
    consume_mana(SPELLS[:magic_missile])
    @boss[:hp] -= 4
  end

  def drain
    consume_mana(SPELLS[:drain])
    @boss[:hp] -= 2
    @player[:hp] += 2
  end

  def apply_effect(name, turns)
    raise 'effect already active' if @effects[name] > 0
    @effects[name] = turns
  end

  def shield
    consume_mana(SPELLS[:shield])
    apply_effect(:shield, 6)
  end

  def poison
    consume_mana(SPELLS[:poison])
    apply_effect(:poison, 6)
  end

  def recharge
    consume_mana(SPELLS[:recharge])
    apply_effect(:recharge, 5)
  end

  def handle_effect
    @effects.each do |effect, turns|
      next if turns <= 0
      case effect
      when :shield then @magic_armor = 7
      when :poison then @boss[:hp] -= 3
      when :recharge then @player[:mana] += 101
      end
      @effects[effect] -= 1
      @magic_armor = 0 if effect == :shield && @effects[effect].zero?
    end
  end

  def player_turn(spell)
    handle_effect
    return if allowed_spells.empty?
    send(spell)
  end

  def boss_turn
    handle_effect
    return if done?
    damage = [@boss[:damage] - @magic_armor, 1].max
    @player[:hp] -= damage
  end

  def run(spells)
    spells.each do |spell|
      player_turn(spell)
      return win_or_loss? if done?
      boss_turn
      return win_or_loss? if done?
    end
    :tie
  end
end

player = { hp: 10, mana: 250 }
boss = { hp: 13, damage: 8 }
rpg = RPGSim.new(player, boss)
assert(rpg.run(%i[poison magic_missile]) == :win)

boss[:hp] += 1
rpg = RPGSim.new(player, boss)
assert(rpg.run(%i[recharge shield drain poison magic_missile]) == :win)

def spells_after(klass, player, boss, spells)
  rpg = klass.new(player, boss)
  state = rpg.run(spells)
  return state unless state == :tie
  rpg.handle_effect
  spells = rpg.allowed_spells
  return :loss if spells.empty?
  spells
end

def heuristic(spells, max)
  spells.map { |s| SPELLS[s] }.sum < max
end

def try_all_the_turns(klass, player, boss, max, prefix = [], &block)
  return unless heuristic(prefix, max)
  spells = spells_after(klass, player, boss, prefix)
  if spells.is_a?(Symbol)
    yield(prefix, spells)
    return
  end
  spells.each do |spell|
    try_all_the_turns(klass, player, boss, max, prefix + [spell], &block)
  end
end

def easy(input)
  player = { hp: 50, mana: 500 }
  boss_hp, boss_damage = input
  boss = { hp: boss_hp, damage: boss_damage }
  # max mana spent derived from trying out random answers
  try_all_the_turns(RPGSim, player, boss, 1100) do |spells, result|
    return spells.map { |s| SPELLS[s] }.sum if result == :win
  end
  raise 'no winning route'
end

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# On the next run through the game, you increase the difficulty to
# hard.

# At the start of each player turn (before any other effects apply),
# you lose 1 hit point. If this brings you to or below 0 hit points,
# you lose.

# With the same starting stats for you and the boss, what is the least
# amount of mana you can spend and still win the fight?

class HardRPGSim < RPGSim
  def player_turn(spell)
    @player[:hp] -= 1
    return if done?
    super(spell)
  end
end

def hard(input)
  player = { hp: 50, mana: 500 }
  boss_hp, boss_damage = input
  boss = { hp: boss_hp, damage: boss_damage }
  # max mana spent derived from trying out random answers
  answers = []
  try_all_the_turns(HardRPGSim, player, boss, 1300) do |spells, result|
    answers << spells.map { |s| SPELLS[s] }.sum if result == :win
  end
  raise 'no winning route' if answers.empty?
  answers.min
end

puts "hard(input): #{hard(input)}"
