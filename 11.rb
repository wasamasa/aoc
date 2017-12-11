require_relative 'util'

# --- Day 11: Hex Ed ---

# Crossing the bridge, you've barely reached the other side of the
# stream when a program comes up to you, clearly in distress. "It's my
# child process," she says, "he's gotten lost in an infinite grid!"

# Fortunately for her, you have plenty of experience with infinite grids.

# Unfortunately for you, it's a hex grid.

# The hexagons ("hexes") in this grid are aligned such that adjacent
# hexes can be found to the north, northeast, southeast, south,
# southwest, and northwest:

#       \ n  /
#     nw +--+ ne
#       /    \
#     -+      +-
#       \    /
#     sw +--+ se
#       / s  \

# You have the path the child process took. Starting where he started,
# you need to determine the fewest number of steps required to reach
# him. (A "step" means to move from the hex you are in to any adjacent
# hex.)

# For example:

# - ne,ne,ne is 3 steps away.
# - ne,ne,sw,sw is 0 steps away (back where you started).
# - ne,ne,s,s is 2 steps away (se,se).
# - se,sw,se,sw,sw is 3 steps away (s,s,sw).

class HexCoord
  attr_accessor :x, :y, :z

  def initialize
    # NOTE: this uses the cube representation from
    # https://www.redblobgames.com/grids/hexagons/
    @x = 0
    @y = 0
    @z = 0
  end

  def n
    @x += 1
    @z -= 1
  end

  def ne
    @x += 1
    @y -= 1
  end

  def se
    @z += 1
    @y -= 1
  end

  def s
    @z += 1
    @x -= 1
  end

  def sw
    @y += 1
    @x -= 1
  end

  def nw
    @y += 1
    @z -= 1
  end

  def distance(coord)
    ((@x - coord.x).abs +
     (@y - coord.y).abs +
     (@z - coord.z).abs) / 2
  end
end

input = File.open('11.txt') { |f| f.readline.chomp.split(',').map(&:to_sym) }

def easy(directions)
  a = HexCoord.new
  b = HexCoord.new
  directions.each { |direction| b.send(direction) }
  b.distance(a)
end

assert(easy([:ne, :ne, :ne]) == 3)
assert(easy([:ne, :ne, :sw, :sw]) == 0)
assert(easy([:ne, :ne, :s, :s]) == 2)
assert(easy([:se, :sw, :se, :sw, :sw]) == 3)

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# How many steps away is the furthest he ever got from his starting position?

def hard(directions)
  a = HexCoord.new
  b = HexCoord.new
  max_distance = 0
  directions.each do |direction|
    b.send(direction)
    max_distance = [b.distance(a), max_distance].max
  end
  max_distance
end

puts "hard(input): #{hard(input)}"
