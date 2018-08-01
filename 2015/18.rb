require_relative 'util'

# --- Day 18: Like a GIF For Your Yard ---

# After the million lights incident, the fire code has gotten
# stricter: now, at most ten thousand lights are allowed. You arrange
# them in a 100x100 grid.

# Never one to let you down, Santa again mails you instructions on the
# ideal lighting configuration. With so few lights, he says, you'll
# have to resort to animation.

# Start by setting your lights to the included initial configuration
# (your puzzle input). A # means "on", and a . means "off".

# Then, animate your grid in steps, where each step decides the next
# configuration based on the current one. Each light's next state
# (either on or off) depends on its current state and the current
# states of the eight lights adjacent to it (including
# diagonals). Lights on the edge of the grid might have fewer than
# eight neighbors; the missing ones always count as "off".

# For example, in a simplified 6x6 grid, the light marked A has the
# neighbors numbered 1 through 8, and the light marked B, which is on
# an edge, only has the neighbors marked 1 through 5:

#     1B5...
#     234...
#     ......
#     ..123.
#     ..8A4.
#     ..765.

# The state a light should have next is based on its current state (on
# or off) plus the number of neighbors that are on:

# - A light which is on stays on when 2 or 3 neighbors are on, and
#   turns off otherwise.
# - A light which is off turns on if exactly 3 neighbors are on, and
#   stays off otherwise.

# All of the lights update simultaneously; they all consider the same
# current state before moving to the next.

# Here's a few steps from an example configuration of another 6x6
# grid:

#     Initial state:
#     .#.#.#
#     ...##.
#     #....#
#     ..#...
#     #.#..#
#     ####..
#
#     After 1 step:
#     ..##..
#     ..##.#
#     ...##.
#     ......
#     #.....
#     #.##..
#
#     After 2 steps:
#     ..###.
#     ......
#     ..###.
#     ......
#     .#....
#     .#....
#
#     After 3 steps:
#     ...#..
#     ......
#     ...#..
#     ..##..
#     ......
#     ......
#
#     After 4 steps:
#     ......
#     ......
#     ..##..
#     ..##..
#     ......
#     ......

# After 4 steps, this example has four lights on.

# In your grid of 100x100 lights, given your initial configuration,
# how many lights are on after 100 steps?

input = File.open('18.txt') { |f| f.readlines.map { |l| l.chomp.chars } }
test_input = ".#.#.#\n...##.\n#....#\n..#...\n#.#..#\n####..".split("\n")
                                                             .map(&:chars)

class Grid
  def initialize(input)
    @grid = input
    @size = input[0].length
  end

  def at(x, y)
    return nil if x < 0 || y < 0
    row = @grid[y]
    return nil unless row
    row[x]
  end

  def neighbors(x, y)
    count = 0
    offsets = [[1, 0], [1, 1], [0, 1], [-1, 1],
               [-1, 0], [-1, -1], [0, -1], [1, -1]]
    offsets.each do |xo, yo|
      count += 1 if at(x + xo, y + yo) == '#'
    end
    count
  end

  def evolve
    result = Array.new(@size) { Array.new(@size) }
    (0...@size).each do |y|
      (0...@size).each do |x|
        is_on = at(x, y) == '#'
        neighbors = neighbors(x, y)
        if is_on
          result[y][x] = [2, 3].include?(neighbors) ? '#' : '.'
        else
          result[y][x] = (neighbors == 3 ? '#' : '.')
        end
      end
    end
    @grid = result
  end

  def show
    @grid.each do |row|
      puts row.join
    end
    puts
  end

  def count
    sum = 0
    @grid.each do |row|
      sum += row.count('#')
    end
    sum
  end
end

def easy(input, steps)
  grid = Grid.new(input)
  steps.times { grid.evolve }
  grid.count
end

assert(easy(test_input, 4) == 4)
puts "easy(input, 100): #{easy(input, 100)}"

# --- Part Two ---

# You flip the instructions over; Santa goes on to point out that this
# is all just an implementation of Conway's Game of Life. At least, it
# was, until you notice that something's wrong with the grid of lights
# you bought: four lights, one in each corner, are stuck on and can't
# be turned off. The example above will actually run like this:

#     Initial state:
#     ##.#.#
#     ...##.
#     #....#
#     ..#...
#     #.#..#
#     ####.#
#
#     After 1 step:
#     #.##.#
#     ####.#
#     ...##.
#     ......
#     #...#.
#     #.####
#
#     After 2 steps:
#     #..#.#
#     #....#
#     .#.##.
#     ...##.
#     .#..##
#     ##.###
#
#     After 3 steps:
#     #...##
#     ####.#
#     ..##.#
#     ......
#     ##....
#     ####.#
#
#     After 4 steps:
#     #.####
#     #....#
#     ...#..
#     .##...
#     #.....
#     #.#..#
#
#     After 5 steps:
#     ##.###
#     .##..#
#     .##...
#     .##...
#     #.#...
#     ##...#

# After 5 steps, this example now has 17 lights on.

# In your grid of 100x100 lights, given your initial configuration,
# but with the four corners always in the on state, how many lights
# are on after 100 steps?

class StuckGrid < Grid
  def simulate_stuck_lights
    @grid[0][0] = '#'
    @grid[@size - 1][0] = '#'
    @grid[0][@size - 1] = '#'
    @grid[@size - 1][@size - 1] = '#'
  end

  def initialize(input)
    super
    simulate_stuck_lights
  end

  def evolve
    super
    simulate_stuck_lights
  end
end

def hard(input, steps)
  grid = StuckGrid.new(input)
  steps.times { grid.evolve }
  grid.count
end

assert(hard(test_input, 5) == 17)
puts "hard(input, 100): #{hard(input, 100)}"
