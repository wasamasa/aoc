require_relative 'util'

# --- Day 23: Opening the Turing Lock ---

# Little Jane Marie just got her very first computer for Christmas
# from some unknown benefactor. It comes with instructions and an
# example program, but the computer itself seems to be
# malfunctioning. She's curious what the program does, and would like
# you to help her run it.

# The manual explains that the computer supports two registers and six
# instructions (truly, it goes on to remind the reader, a
# state-of-the-art technology). The registers are named a and b, can
# hold any non-negative integer, and begin with a value of 0. The
# instructions are as follows:

# - `hlf r` sets register r to half its current value, then continues
#   with the next instruction.
# - `tpl r` sets register r to triple its current value, then
#   continues with the next instruction.
# - `inc r` increments register r, adding 1 to it, then continues with
#   the next instruction.
# - `jmp offset` is a jump; it continues with the instruction offset
#   away relative to itself.
# - `jie r, offset` is like jmp, but only jumps if register r is even
#   ("jump if even").
# - `jio r, offset` is like jmp, but only jumps if register r is 1
#   ("jump if one", not odd).

# All three jump instructions work with an offset relative to that
# instruction. The offset is always written with a prefix + or - to
# indicate the direction of the jump (forward or backward,
# respectively). For example, `jmp +1` would simply continue with the
# next instruction, while `jmp +0` would continuously jump back to
# itself forever.

# The program exits when it tries to run an instruction beyond the
# ones defined.

# For example, this program sets a to 2, because the jio instruction
# causes it to skip the tpl instruction:

#     inc a
#     jio a, +2
#     tpl a
#     inc a

# What is the value in register b when the program in your puzzle
# input is finished executing?

input = File.open('23.txt') { |f| f.readlines.map(&:chomp) }
test_input = "inc a\njio a, +2\ntpl a\ninc a".split("\n")

class Computer
  attr_accessor :registers

  def initialize(input)
    @registers = { a: 0, b: 0 }
    @program = input.map { |line| parse(line) }
    @pc = 0
  end

  def parse_arg(arg)
    if arg[/^[-+]?\d+$/]
      arg.to_i
    else
      arg.to_sym
    end
  end

  def parse(line)
    line.split(/,?\s/).map { |arg| parse_arg(arg) }
  end

  def fetch
    assert(@pc < @program.length)
    result = @program[@pc]
    @pc += 1
    result
  end

  def hlf(reg)
    @registers[reg] /= 2
  end

  def tpl(reg)
    @registers[reg] *= 3
  end

  def inc(reg)
    @registers[reg] += 1
  end

  def jmp(offset)
    # HACK: account for fetch always incrementing @pc
    @pc += offset - 1
  end

  def jie(reg, offset)
    @pc += offset - 1 if @registers[reg].even?
  end

  def jio(reg, offset)
    @pc += offset - 1 if @registers[reg] == 1
  end

  def step
    op, *args = fetch
    send(op, *args)
  end

  def done?
    @pc < 0 || !@program[@pc] || @recovered
  end

  def run
    step until done?
  end
end

computer = Computer.new(test_input)
computer.run
assert(computer.registers[:a] == 2)

def easy(input)
  computer = Computer.new(input)
  computer.run
  computer.registers[:b]
end

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# The unknown benefactor is very thankful for releasi-- er, helping
# little Jane Marie with her computer. Definitely not to distract you,
# what is the value in register b after the program is finished
# executing if register a starts as 1 instead?

def hard(input)
  computer = Computer.new(input)
  computer.registers[:a] = 1
  computer.run
  computer.registers[:b]
end

puts "hard(input): #{hard(input)}"
