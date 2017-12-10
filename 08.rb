require_relative 'util'

# --- Day 8: I Heard You Like Registers ---

# You receive a signal directly from the CPU. Because of your recent
# assistance with jump instructions, it would like you to compute the
# result of a series of unusual register instructions.

# Each instruction consists of several parts: the register to modify,
# whether to increase or decrease that register's value, the amount by
# which to increase or decrease it, and a condition. If the condition
# fails, skip the instruction without modifying the register. The
# registers all start at 0. The instructions look like this:

#     b inc 5 if a > 1
#     a inc 1 if b < 5
#     c dec -10 if a >= 1
#     c inc -20 if c == 10

# These instructions would be processed as follows:

# - Because a starts at 0, it is not greater than 1, and so b is not
#   modified.
# - a is increased by 1 (to 1) because b is less than 5 (it is 0).
# - c is decreased by -10 (to 10) because a is now greater than or
#   equal to 1 (it is 1).
# - c is increased by -20 (to -10) because c is equal to 10.

# After this process, the largest value in any register is 1.

# You might also encounter <= (less than or equal to) or != (not equal
# to). However, the CPU doesn't have the bandwidth to tell you what
# all the registers are named, and leaves that to you to determine.

# What is the largest value in any register after completing the
# instructions in your puzzle input?

def parse(line)
  reg, op, arg, _, reg2, op2, arg2 = line.split
  [reg.to_sym, op.to_sym, arg.to_i, reg2.to_sym, op2.to_sym, arg2.to_i]
end

input = File.open('08.txt', &:readlines)
test_input = ['b inc 5 if a > 1',
              'a inc 1 if b < 5',
              'c dec -10 if a >= 1',
              'c inc -20 if c == 10']

class RegisterCPU
  attr_reader :highest

  def initialize(instructions)
    @instructions = instructions
    @ip = 0
    @registers = Hash.new { |h, k| h[k] = 0 }
    @highest = 0
  end

  def step
    instruction = @instructions[@ip]
    @ip += 1
    reg, op, arg, reg2, op2, arg2 = instruction
    return unless @registers[reg2].send(op2, arg2)
    case op
    when :inc then @registers[reg] += arg
    when :dec then @registers[reg] -= arg
    end
    @highest = @registers[reg] if @registers[reg] > @highest
  end

  def exit?
    @ip >= @instructions.length
  end

  def max_register
    @registers.max_by { |_, v| v }[1]
  end
end

def easy(instructions)
  cpu = RegisterCPU.new(instructions.map { |line| parse(line) })
  cpu.step until cpu.exit?
  cpu.max_register
end

assert(easy(test_input) == 1)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# To be safe, the CPU also needs to know the highest value held in any
# register during this process so that it can decide how much memory
# to allocate to these operations. For example, in the above
# instructions, the highest value ever held was 10 (in register c
# after the third instruction was evaluated).

def hard(instructions)
  cpu = RegisterCPU.new(instructions.map { |line| parse(line) })
  cpu.step until cpu.exit?
  cpu.highest
end

assert(hard(test_input) == 10)
puts "hard(input): #{hard(input)}"
