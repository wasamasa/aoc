require_relative 'util'

# --- Day 23: Coprocessor Conflagration ---

# You decide to head directly to the CPU and fix the printer from
# there. As you get close, you find an experimental coprocessor doing
# so much work that the local programs are afraid it will halt and
# catch fire. This would cause serious issues for the rest of the
# computer, so you head in and see what you can do.

# The code it's running seems to be a variant of the kind you saw
# recently on that tablet. The general functionality seems very
# similar, but some of the instructions are different:

# - set X Y sets register X to the value of Y.
# - sub X Y decreases register X by the value of Y.
# - mul X Y sets register X to the result of multiplying the value
#   contained in register X by the value of Y.
# - jnz X Y jumps with an offset of the value of Y, but only if the
#   value of X is not zero. (An offset of 2 skips the next
#   instruction, an offset of -1 jumps to the previous instruction,
#   and so on.)

# Only the instructions listed above are used. The eight registers
# here, named a through h, all start at 0.

# The coprocessor is currently set to some kind of debug mode, which
# allows for testing, but prevents it from doing any meaningful work.

# If you run the program (your puzzle input), how many times is the
# mul instruction invoked?

class Coprocessor
  attr_reader :muls

  def initialize
    @registers = { a: 0, b: 0, c: 0, d: 0, e: 0, f: 0, g: 0, h: 0 }
    @program = []
    @pc = 0
    @muls = 0
  end

  def load(input)
    @program = input.split("\n").map { |line| parse(line) }
  end

  def parse(line)
    line.split(' ').map { |arg| parse_arg(arg) }
  end

  def parse_arg(arg)
    if arg[/^-?\d+$/]
      arg.to_i
    else
      arg.to_sym
    end
  end

  def fetch
    assert(@pc < @program.length)
    result = @program[@pc]
    @pc += 1
    result
  end

  def lookup(reg_or_arg)
    if reg_or_arg.is_a? Symbol
      @registers[reg_or_arg]
    else
      reg_or_arg
    end
  end

  def set(reg, arg)
    @registers[reg] = lookup(arg)
  end

  def sub(reg, arg)
    @registers[reg] -= lookup(arg)
  end

  def mul(reg, arg)
    @registers[reg] *= lookup(arg)
    @muls += 1
  end

  def jnz(arg1, arg2)
    # HACK: account for fetch always incrementing @pc
    @pc += lookup(arg2) - 1 unless lookup(arg1).zero?
  end

  def step
    op, *args = fetch
    send(op, *args)
  end

  def done?
    @pc < 0 || !@program[@pc]
  end

  def run
    step until done?
  end
end

input = File.open('23.txt') { |f| f.read.chomp }

def easy(input)
  coprocessor = Coprocessor.new
  coprocessor.load(input)
  coprocessor.run
  coprocessor.muls
end

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# Now, it's time to fix the problem.

# The debug mode switch is wired directly to register a. You flip the
# switch, which makes register a now start at 1 when the program is
# executed.

# Immediately, the coprocessor begins to overheat. Whoever wrote this
# program obviously didn't choose a very efficient
# implementation. You'll need to optimize the program if it has any
# hope of completing before Santa needs that printer working.

# The coprocessor's ultimate goal is to determine the final value left
# in register h once the program completes. Technically, if it had
# that... it wouldn't even need to run the program.

# After setting register a to 1, if the program were to run to
# completion, what value would be left in register h?

a = 1
b = 79
c = b
h = 0
if a
  b = b * 100 + 100_000
  c = b + 17_000
end
loop do
  f = 1
  d = 2
  loop do
    # e = 2
    # loop do
    #   f = 0 if d * e == b
    #   e += 1
    #   break if e == b
    # end
    f = 0 if (b % d).zero?
    d += 1
    break if d == b
  end
  h += 1 if f.zero?
  break if b == c
  b += 17
end

puts "hard: #{h}"
