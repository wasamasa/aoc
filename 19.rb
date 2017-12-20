require_relative 'util'

# --- Day 19: A Series of Tubes ---

# Somehow, a network packet got lost and ended up here. It's trying to
# follow a routing diagram (your puzzle input), but it's confused
# about where to go.

# Its starting point is just off the top of the diagram. Lines (drawn
# with |, -, and +) show the path it needs to take, starting by going
# down onto the only line connected to the top of the diagram. It
# needs to follow this path until it reaches the end (located
# somewhere within the diagram) and stop there.

# Sometimes, the lines cross over each other; in these cases, it needs
# to continue going the same direction, and only turn left or right
# when there's no other option. In addition, someone has left letters
# on the line; these also don't change its direction, but it can use
# them to keep track of where it's been. For example:

#          |
#          |  +--+
#          A  |  C
#      F---|----E|--+
#          |  |  |  D
#          +B-+  +--+

# Given this diagram, the packet needs to take the following path:

# - Starting at the only line touching the top of the diagram, it must
#   go down, pass through A, and continue onward to the first +.
# - Travel right, up, and right, passing through B in the process.
# - Continue down (collecting C), right, and up (collecting D).
# - Finally, go all the way left through E and stopping at F.

# Following the path to the end, the letters it sees on its path are
# ABCDEF.

# The little packet looks up at you, hoping you can help it find the
# way. What letters will it see (in the order it would see them) if it
# follows the path? (The routing diagram is very wide; make sure you
# view it without line wrapping.)

class TubeRunner
  attr_reader :letters, :steps

  def initialize(input)
    @grid = input.split("\n").map { |line| line.bytes.map(&:chr) }
    @height = @grid.length
    @width = @grid[0].length
    @letters = []
    @x = @grid[0].find_index('|')
    @y = 0
    @direction = :down
    @steps = 1
  end

  def loc
    [@x, @y]
  end

  def blank?(arg)
    arg && arg[/^\s*$/]
  end

  def letter?(arg)
    arg && arg[/^[A-Z]$/]
  end

  def char(xy)
    x, y = xy
    return nil if y < 0 || y >= @height
    return nil if x < 0 || x >= @width
    c = @grid[y][x]
    !blank?(c) && c
  end

  def up(xy)
    x, y = xy
    [x, y - 1]
  end

  def down(xy)
    x, y = xy
    [x, y + 1]
  end

  def left(xy)
    x, y = xy
    [x - 1, y]
  end

  def right(xy)
    x, y = xy
    [x + 1, y]
  end

  def continue
    pos = loc
    loop do
      new = send(@direction, pos)
      c = char(new)
      break unless c
      @letters << c if letter?(c)
      @steps += 1
      pos = new
    end
    @x, @y = pos
  end

  def turn
    case @direction
    when :up, :down
      (char(left(loc)) && :left) || (char(right(loc)) && :right)
    when :left, :right
      (char(up(loc)) && :up) || (char(down(loc)) && :down)
    end
  end

  def run
    loop do
      continue
      @direction = turn
      break unless @direction
    end
  end
end

test_input = '     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+
                '

input = File.open('19.txt') { |f| f.read.chomp }

def easy(input)
  runner = TubeRunner.new(input)
  runner.run
  runner.letters.join
end

assert(easy(test_input) == 'ABCDEF')
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# The packet is curious how many steps it needs to go.

# For example, using the same routing diagram from the example above...

#          |
#          |  +--+
#          A  |  C
#      F---|--|-E---+
#          |  |  |  D
#          +B-+  +--+

# ...the packet would go:

# - 6 steps down (including the first line at the top of the diagram).
# - 3 steps right.
# - 4 steps up.
# - 3 steps right.
# - 4 steps down.
# - 3 steps right.
# - 2 steps up.
# - 13 steps left (including the F it stops on).

# This would result in a total of 38 steps.

# How many steps does the packet need to go?

def hard(input)
  runner = TubeRunner.new(input)
  runner.run
  runner.steps
end

assert(hard(test_input) == 38)
puts "hard(input): #{hard(input)}"
