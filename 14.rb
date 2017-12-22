require_relative 'util'
require_relative '10'

# --- Day 14: Disk Defragmentation ---

# Suddenly, a scheduled job activates the system's disk
# defragmenter. Were the situation different, you might sit and watch
# it for a while, but today, you just don't have that kind of
# time. It's soaking up valuable system resources that are needed
# elsewhere, and so the only option is to help it finish its task as
# soon as possible.

# The disk in question consists of a 128x128 grid; each square of the
# grid is either free or used. On this disk, the state of the grid is
# tracked by the bits in a sequence of knot hashes.

# A total of 128 knot hashes are calculated, each corresponding to a
# single row in the grid; each hash contains 128 bits which correspond
# to individual grid squares. Each bit of a hash indicates whether
# that square is free (0) or used (1).

# The hash inputs are a key string (your puzzle input), a dash, and a
# number from 0 to 127 corresponding to the row. For example, if your
# key string were `flqrgnkx`, then the first row would be given by the
# bits of the knot hash of `flqrgnkx-0`, the second row from the bits
# of the knot hash of `flqrgnkx-1`, and so on until the last row,
# `flqrgnkx-127`.

# The output of a knot hash is traditionally represented by 32
# hexadecimal digits; each of these digits correspond to 4 bits, for a
# total of 4 * 32 = 128 bits. To convert to bits, turn each
# hexadecimal digit to its equivalent binary value, high-bit first: 0
# becomes `0000`, 1 becomes `0001`, e becomes `1110`, f becomes
# `1111`, and so on; a hash that begins with `a0c2017...` in
# hexadecimal would begin with `10100000110000100000000101110000...`
# in binary.

# Continuing this process, the first 8 rows and columns for key
# `flqrgnkx` appear as follows, using `#` to denote used squares, and
# `.` to denote free ones:

#     ##.#.#..-->
#     .#.#.#.#
#     ....#.#.
#     #.#.##.#
#     .##.#...
#     ##..#..#
#     .#...#..
#     ##.#.##.-->
#     |      |
#     V      V

# In this example, 8108 squares are used across the entire 128x128 grid.

# Given your actual key string, how many squares are used?

# Your puzzle input is `jxqlasbh`.

def knothash(string)
  hasher = KnotHash.new(256, string.bytes + [17, 31, 73, 47, 23])
  64.times { hasher.round }
  hasher.hash
end

def hash_to_bits(string)
  explode(string).map { |c| c.to_i(16).to_s(2).rjust(4, '0') }.join
end

def grid(keystring)
  (0..127).map { |i| hash_to_bits(knothash("#{keystring}-#{i}")) }.join("\n")
end

def easy(keystring)
  grid(keystring).count('1')
end

input = 'jxqlasbh'

# assert(hash_to_bits('a0c2017') == '1010000011000010000000010111')
# assert(easy('flqrgnkx') == 8108)
# puts "easy(input): #{easy(input)}"

# --- Part Two ---

# Now, all the defragmenter needs to know is the number of regions. A
# region is a group of used squares that are all adjacent, not
# including diagonals. Every used square is in exactly one region:
# lone used squares form their own isolated regions, while several
# adjacent squares all count as a single region.

# In the example above, the following nine regions are visible, each
# marked with a distinct digit:

#     11.2.3..-->
#     .1.2.3.4
#     ....5.6.
#     7.8.55.9
#     .88.5...
#     88..5..8
#     .8...8..
#     88.8.88.-->
#     |      |
#     V      V

# Of particular interest is the region marked 8; while it does not
# appear contiguous in this small view, all of the squares marked 8
# are connected when considering the whole 128x128 grid. In total, in
# this example, 1242 regions are present.

# How many regions are present given your key string?

require 'set'

class Grid
  attr_accessor :grid

  def initialize(input)
    @grid = input.split.map do |line|
      explode(line).map(&:to_i)
    end
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def each
    @grid.each_with_index do |line, y|
      line.each_with_index do |char, x|
        yield(x, y, char)
      end
    end
  end

  def used
    result = Set.new
    each { |x, y, c| result << [x, y] if c == 1 }
    result
  end

  def at(x, y)
    return nil if x < 0 || y < 0
    row = @grid[y]
    return nil unless row
    [x, y, row[x]]
  end

  def neighbors(xy)
    result = []
    offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    offsets.each do |xo, yo|
      x, y, char = at(xy[0] + xo, xy[1] + yo)
      result << [x, y] if char == 1
    end
    result
  end

  def component(start, seen = Set.new)
    seen << start
    neighbors(start).each do |coord|
      component(coord, seen) unless seen.include?(coord)
    end
    seen
  end

  def components
    used = self.used
    components = []
    until used.empty?
      component = component(used.first)
      components << component
      used = used.difference(component)
    end
    components
  end
end

def hard(input)
  grid = Grid.new(grid(input))
  grid.components.length
end

assert(hard('flqrgnkx') == 1242)
puts "hard(input): #{hard(input)}"
