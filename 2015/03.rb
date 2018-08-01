require_relative 'util'

# --- Day 3: Perfectly Spherical Houses in a Vacuum ---

# Santa is delivering presents to an infinite two-dimensional grid of
# houses.

# He begins by delivering a present to the house at his starting
# location, and then an elf at the North Pole calls him via radio and
# tells him where to move next. Moves are always exactly one house to
# the north (`^`), south (`v`), east (`>`), or west (`<`). After each
# move, he delivers another present to the house at his new location.

# However, the elf back at the north pole has had a little too much
# eggnog, and so his directions are a little off, and Santa ends up
# visiting some houses more than once. How many houses receive at
# least one present?

# For example:

# - `>` delivers presents to 2 houses: one at the starting location,
#   and one to the east.
# - `^>v<` delivers presents to 4 houses in a square, including twice
#   to the house at his starting/ending location.
# - `^v^v^v^v^v` delivers a bunch of presents to some very lucky
#   children at only 2 houses.

input = File.open('03.txt') { |f| f.read.chomp }

class SantaGrid
  def initialize
    @grid = Hash.new { |h, k| h[k] = 0 }
    @x = 0
    @y = 0
    @grid[[@x, @y]] += 1
  end

  def walk(direction)
    case direction
    when '^' then @y += 1
    when 'v' then @y -= 1
    when '>' then @x += 1
    when '<' then @x -= 1
    end
    @grid[[@x, @y]] += 1
  end

  def visited_houses
    @grid.count # HACK
  end
end

def easy(input)
  grid = SantaGrid.new
  input.each_char { |c| grid.walk(c) }
  grid.visited_houses
end

assert(easy('>') == 2)
assert(easy('^>v<') == 4)
assert(easy('^v^v^v^v^v') == 2)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# The next year, to speed up the process, Santa creates a robot
# version of himself, Robo-Santa, to deliver presents with him.

# Santa and Robo-Santa start at the same location (delivering two
# presents to the same starting house), then take turns moving based
# on instructions from the elf, who is eggnoggedly reading from the
# same script as the previous year.

# This year, how many houses receive at least one present?

# For example:

# - `^v` delivers presents to 3 houses, because Santa goes north, and
#   then Robo-Santa goes south.
# - `^>v<` now delivers presents to 3 houses, and Santa and Robo-Santa
#   end up back where they started.
# - `^v^v^v^v^v` now delivers presents to 11 houses, with Santa going
#   one direction and Robo-Santa going the other.

class SantasGrid < SantaGrid
  def initialize
    super
    @x2 = 0
    @y2 = 0
    @grid[[@x2, @y2]] += 1
  end

  def robo_walk(direction)
    case direction
    when '^' then @y2 += 1
    when 'v' then @y2 -= 1
    when '>' then @x2 += 1
    when '<' then @x2 -= 1
    end
    @grid[[@x2, @y2]] += 1
  end
end

def hard(input)
  grid = SantasGrid.new
  input.each_char.each_slice(2) do |c1, c2|
    grid.walk(c1)
    grid.robo_walk(c2)
  end
  grid.visited_houses
end

assert(hard('^v') == 3)
assert(hard('^>v<') == 3)
assert(hard('^v^v^v^v^v') == 11)
puts "hard(input): #{hard(input)}"
