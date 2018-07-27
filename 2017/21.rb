require_relative 'util'

# --- Day 21: Fractal Art ---

# You find a program trying to generate some art. It uses a strange
# process that involves repeatedly enhancing the detail of an image
# through a set of rules.

# The image consists of a two-dimensional square grid of pixels that
# are either on (#) or off (.). The program always begins with this
# pattern:

#     .#.
#     ..#
#     ###

# Because the pattern is both 3 pixels wide and 3 pixels tall, it is
# said to have a size of 3.

# Then, the program repeats the following process:

# - If the size is evenly divisible by 2, break the pixels up into 2x2
#   squares, and convert each 2x2 square into a 3x3 square by
#   following the corresponding enhancement rule.
# - Otherwise, the size is evenly divisible by 3; break the pixels up
#   into 3x3 squares, and convert each 3x3 square into a 4x4 square by
#   following the corresponding enhancement rule.

# Because each square of pixels is replaced by a larger one, the image
# gains pixels and so its size increases.

# The artist's book of enhancement rules is nearby (your puzzle
# input); however, it seems to be missing rules. The artist explains
# that sometimes, one must rotate or flip the input pattern to find a
# match. (Never rotate or flip the output pattern, though.) Each
# pattern is written concisely: rows are listed as single units,
# ordered top-down, and separated by slashes. For example, the
# following rules correspond to the adjacent patterns:

#     ../.#  =  ..
#               .#

#                     .#.
#     .#./..#/###  =  ..#
#                     ###

#                             #..#
#     #..#/..../#..#/.##.  =  ....
#                             #..#
#                             .##.

# When searching for a rule to use, rotate and flip the pattern as
# necessary. For example, all of the following patterns match the same
# rule:

#     .#.   .#.   #..   ###
#     ..#   #..   #.#   ..#
#     ###   ###   ##.   .#.

# Suppose the book contained the following two rules:

#     ../.# => ##./#../...
#     .#./..#/### => #..#/..../..../#..#

# As before, the program begins with this pattern:

#     .#.
#     ..#
#     ###

# The size of the grid (3) is not divisible by 2, but it is divisible
# by 3. It divides evenly into a single square; the square matches the
# second rule, which produces:

#     #..#
#     ....
#     ....
#     #..#

# The size of this enhanced grid (4) is evenly divisible by 2, so that
# rule is used. It divides evenly into four squares:

#     #.|.#
#     ..|..
#     --+--
#     ..|..
#     #.|.#

# Each of these squares matches the same rule (`../.# =>
# ##./#../...`), three of which require some flipping and rotation to
# line up with the rule. The output for the rule is the same in all
# four cases:

#     ##.|##.
#     #..|#..
#     ...|...
#     ---+---
#     ##.|##.
#     #..|#..
#     ...|...

# Finally, the squares are joined into a new grid:

#     ##.##.
#     #..#..
#     ......
#     ##.##.
#     #..#..
#     ......

# Thus, after 2 iterations, the grid contains 12 pixels that are on.

# How many pixels stay on after 5 iterations?

# .#.  #..  ###  .##
# ..#  #.#  #..  #.#
# ###  ##.  .#.  ..#

# .#.  ##.  ###  ..#
# #..  #.#  ..#  #.#
# ###  #..  .#.  .##

class Array
  def slice(x, y, size)
    rows = drop(y).take(size)
    rows.map { |row| row.drop(x).take(size) }
  end

  def split(size)
    arrays = []
    ycount = length / size
    xcount = self[0].length / size
    ycount.times do |y|
      xcount.times do |x|
        arrays << slice(x * size, y * size, size)
      end
    end
    arrays
  end

  def combine(width)
    each_slice(width).flat_map { |ary| ary.transpose.map(&:flatten) }
  end

  def flipv
    map(&:reverse)
  end

  def rotate90
    transpose.map(&:reverse)
  end

  def rotations
    ary = self
    result = [ary]
    3.times do
      ary = ary.rotate90
      result << ary
    end
    result
  end

  def variations
    rotated = rotations
    flipped = rotated.map(&:flipv)
    rotated + flipped
  end
end

def to_grid(input)
  input.split('/').map { |line| explode(line) }
end

class Grid
  def initialize(rules)
    @rows = to_grid('.#./..#/###')
    @rules = {}
    rules.each do |k, v|
      k.variations.each do |variation|
        @rules[variation] = v
      end
    end
  end

  def divisible(by)
    (@rows[0].length % by).zero? && by
  end

  def divisor
    divisible(2) || divisible(3) || raise("this shouldn't happen")
  end

  def grow
    size = divisor
    width = @rows[0].length / size
    subgrids = @rows.split(size)
    @rows = subgrids.map { |subgrid| @rules[subgrid] }.combine(width)
  end

  def on
    @rows.map { |row| row.count('#') }.sum
  end

  def to_s
    @rows.map(&:join).join("\n")
  end
end

def parse(input)
  lines = input.split("\n")
  lines.map { |line| line.split(' => ').map { |part| to_grid(part) } }.to_h
end

test_input = "../.# => ##./#../...\n.#./..#/### => #..#/..../..../#..#"
input = File.open('21.txt') { |f| f.read.chomp }

def easy(input, iterations)
  rules = parse(input)
  grid = Grid.new(rules)
  iterations.times { grid.grow }
  grid.on
end

assert(easy(test_input, 2) == 12)
puts("easy(input, 5): #{easy(input, 5)}")

# --- Part Two ---

# How many pixels stay on after 18 iterations?

alias hard easy
puts("hard(input, 18): #{hard(input, 18)}")
