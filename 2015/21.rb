require_relative 'util'

# --- Day 21: RPG Simulator 20XX ---

# Little Henry Case got a new video game for Christmas. It's an RPG,
# and he's stuck on a boss. He needs to know what equipment to buy at
# the shop. He hands you the controller.

# In this game, the player (you) and the enemy (the boss) take turns
# attacking. The player always goes first. Each attack reduces the
# opponent's hit points by at least 1. The first character at or below
# 0 hit points loses.

# Damage dealt by an attacker each turn is equal to the attacker's
# damage score minus the defender's armor score. An attacker always
# does at least 1 damage. So, if the attacker has a damage score of 8,
# and the defender has an armor score of 3, the defender loses 5 hit
# points. If the defender had an armor score of 300, the defender
# would still lose 1 hit point.

# Your damage score and armor score both start at zero. They can be
# increased by buying items in exchange for gold. You start with no
# items and have as much gold as you need. Your total damage or armor
# is equal to the sum of those stats from all of your items. You have
# 100 hit points.

# Here is what the item shop is selling:

#     Weapons:    Cost  Damage  Armor
#     Dagger        8     4       0
#     Shortsword   10     5       0
#     Warhammer    25     6       0
#     Longsword    40     7       0
#     Greataxe     74     8       0
#
#     Armor:      Cost  Damage  Armor
#     Leather      13     0       1
#     Chainmail    31     0       2
#     Splintmail   53     0       3
#     Bandedmail   75     0       4
#     Platemail   102     0       5
#
#     Rings:      Cost  Damage  Armor
#     Damage +1    25     1       0
#     Damage +2    50     2       0
#     Damage +3   100     3       0
#     Defense +1   20     0       1
#     Defense +2   40     0       2
#     Defense +3   80     0       3

# You must buy exactly one weapon; no dual-wielding. Armor is
# optional, but you can't use more than one. You can buy 0-2 rings (at
# most one for each hand). You must use any items you buy. The shop
# only has one of each item, so you can't buy, for example, two rings
# of Damage +3.

# For example, suppose you have 8 hit points, 5 damage, and 5 armor,
# and that the boss has 12 hit points, 7 damage, and 2 armor:

# - The player deals 5-2 = 3 damage; the boss goes down to 9 hit
#   points.
# - The boss deals 7-5 = 2 damage; the player goes down to 6 hit
#   points.
# - The player deals 5-2 = 3 damage; the boss goes down to 6 hit
#   points.
# - The boss deals 7-5 = 2 damage; the player goes down to 4 hit
#   points.
# - The player deals 5-2 = 3 damage; the boss goes down to 3 hit
#   points.
# - The boss deals 7-5 = 2 damage; the player goes down to 2 hit
#   points.
# - The player deals 5-2 = 3 damage; the boss goes down to 0 hit
# - points.

# In this scenario, the player wins! (Barely.)

# You have 100 hit points. The boss's actual stats are in your puzzle
# input. What is the least amount of gold you can spend and still win
# the fight?

input = File.open('21.txt') { |f| f.read.scan(/\d+/).map(&:to_i) }

class RPGSim
  def initialize(player, boss)
    @player = player.clone
    @boss = boss.clone
  end

  def done?
    @player[:hp] <= 0 || @boss[:hp] <= 0
  end

  def win_or_loss?
    return :loss if @player[:hp] <= 0
    return :win if @boss[:hp] <= 0
    nil
  end

  def player_turn
    damage = [@player[:damage] - @boss[:armor], 1].max
    @boss[:hp] -= damage
  end

  def boss_turn
    damage = [@boss[:damage] - @player[:armor], 1].max
    @player[:hp] -= damage
  end

  def run
    loop do
      player_turn
      return win_or_loss? if done?
      boss_turn
      return win_or_loss? if done?
    end
  end
end

rpg = RPGSim.new({ hp: 8, damage: 5, armor: 5 },
                 { hp: 12, damage: 7, armor: 2 })
assert(rpg.run == :win)

WEAPONS = { dagger:     { cost: 8,  damage: 4, armor: 0 },
            shortsword: { cost: 10, damage: 5, armor: 0 },
            warhammer:  { cost: 25, damage: 6, armor: 0 },
            longsword:  { cost: 40, damage: 7, armor: 0 },
            greataxe:   { cost: 74, damage: 8, armor: 0 } }.freeze
ARMOR = { leather:    { cost: 13,  damage: 0, armor: 1 },
          chainmail:  { cost: 31,  damage: 0, armor: 2 },
          splintmail: { cost: 53,  damage: 0, armor: 3 },
          bandedmail: { cost: 75,  damage: 0, armor: 4 },
          platemail:  { cost: 102, damage: 0, armor: 5 } }.freeze
RINGS = { damage1: { cost: 25,  damage: 1, armor: 0 },
          damage2: { cost: 50,  damage: 2, armor: 0 },
          damage3: { cost: 100, damage: 3, armor: 0 },
          defense1: { cost: 20, damage: 0, armor: 1 },
          defense2: { cost: 40, damage: 0, armor: 2 },
          defense3: { cost: 80, damage: 0, armor: 3 } }.freeze
EQUIPMENT = WEAPONS.merge(ARMOR).merge(RINGS).freeze

def equipment_choices
  weapons = WEAPONS.keys.combination(1).to_a
  armor = ARMOR.keys.combination(1).to_a + [[]]
  rings = RINGS.keys.combination(1).to_a + RINGS.keys.combination(2).to_a + [[]]
  weapons.product(armor, rings)
end

def make_equipment(choice)
  cost = 0
  damage = 0
  armor = 0
  choice.each do |things|
    things.each do |thing|
      cost += EQUIPMENT[thing][:cost]
      damage += EQUIPMENT[thing][:damage]
      armor += EQUIPMENT[thing][:armor]
    end
  end
  [cost, damage, armor]
end

def easy(input)
  boss_hp, boss_damage, boss_armor = input
  boss = { hp: boss_hp, damage: boss_damage, armor: boss_armor }
  player_hp = 100
  ranked_choices = equipment_choices.map { |c| make_equipment(c) }
                                    .sort_by { |c| c[0] }
  ranked_choices.each do |choice|
    cost, player_damage, player_armor = choice
    player = { hp: player_hp, damage: player_damage, armor: player_armor }
    rpg = RPGSim.new(player, boss)
    return cost if rpg.run == :win
  end
end

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# Turns out the shopkeeper is working with the boss, and can persuade you to buy whatever items he wants. The other rules still apply, and he still only has one of each item.

# What is the most amount of gold you can spend and still lose the fight?

def hard(input)
  boss_hp, boss_damage, boss_armor = input
  boss = { hp: boss_hp, damage: boss_damage, armor: boss_armor }
  player_hp = 100
  ranked_choices = equipment_choices.map { |c| make_equipment(c) }
                                    .sort_by { |c| c[0] }.reverse
  ranked_choices.each do |choice|
    cost, player_damage, player_armor = choice
    player = { hp: player_hp, damage: player_damage, armor: player_armor }
    rpg = RPGSim.new(player, boss)
    return cost if rpg.run == :loss
  end
end

puts "hard(input): #{hard(input)}"
