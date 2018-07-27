require_relative 'util'

# --- Day 16: Permutation Promenade ---

# You come upon a very unusual sight; a group of programs here appear
# to be dancing.

# There are sixteen programs in total, named a through p. They start
# by standing in a line: a stands in position 0, b stands in position
# 1, and so on until p, which stands in position 15.

# The programs' dance consists of a sequence of dance moves:

# - Spin, written sX, makes X programs move from the end to the front,
#   but maintain their order otherwise. (For example, s3 on abcde
#   produces cdeab).
# - Exchange, written xA/B, makes the programs at positions A and B
#   swap places.
# - Partner, written pA/B, makes the programs named A and B swap
#   places.

# For example, with only five programs standing in a line (abcde),
# they could do the following dance:

# - s1, a spin of size 1: eabcd.
# - x3/4, swapping the last two programs: eabdc.
# - pe/b, swapping programs e and b: baedc.

# After finishing their dance, the programs end up in order baedc.

# You watch the dance for a while and record their dance moves (your
# puzzle input). In what order are the programs standing after their
# dance?

class Dance
  def initialize(count, input)
    @programs = (1..count).map { |i| (i + 96).chr }
    @moves = input.split(',').map { |item| parse(item) }
    @seen = {}
    @steps = 0
  end

  def parse(item)
    case item
    when /^s(\d+)$/ then [:spin, $1.to_i]
    when /^x(\d+)\/(\d+)$/ then [:swap_index, $1.to_i, $2.to_i]
    when /^p([a-z])\/([a-z])$/ then [:swap, $1, $2]
    end
  end

  def start
    @seen[state] = @steps

    @moves.each do |move|
      command, *args = move
      send(command, *args)
    end

    @steps += 1
  end

  def spin(count)
    @programs.rotate!(@programs.length - count)
  end

  def swap_index(i, j)
    x = @programs[i]
    y = @programs[j]
    @programs[i] = y
    @programs[j] = x
  end

  def swap(a, b)
    swap_index(@programs.find_index(a), @programs.find_index(b))
  end

  def state
    @programs.join
  end

  def cycle?
    @seen.include?(state)
  end

  def cycle_size
    @steps - @seen[state]
  end
end

test_input = 's1,x3/4,pe/b'
input = File.open('16.txt') { |f| f.read.chomp }

def easy(count, input)
  dance = Dance.new(count, input)
  dance.start
  dance.state
end

assert(easy(5, test_input) == 'baedc')
puts "easy(16, input): #{easy(16, input)}"

# --- Part Two ---

# Now that you're starting to get a feel for the dance moves, you turn
# your attention to the dance as a whole.

# Keeping the positions they ended up in from their previous dance,
# the programs perform it again and again: including the first dance,
# a total of one billion (1000000000) times.

# In the example above, their second dance would begin with the order
# baedc, and use the same dance moves:

# - s1, a spin of size 1: cbaed.
# - x3/4, swapping the last two programs: cbade.
# - pe/b, swapping programs e and b: ceadb.

# In what order are the programs standing after their billion dances?

def hard(count, input, rounds)
  dance = Dance.new(count, input)
  i = 0
  skipped = false
  while i < rounds
    dance.start
    if dance.cycle? && !skipped
      puts "Detected cycle size of #{dance.cycle_size}"
      print "Skipping from #{i} to... "
      i = rounds - (rounds - i) % dance.cycle_size
      puts i
      skipped = true
    end
    i += 1
  end
  dance.state
end

assert(hard(5, test_input, 2) == 'ceadb')
puts "hard(16, input, 1_000_000_000): #{hard(16, input, 1_000_000_000)}"
