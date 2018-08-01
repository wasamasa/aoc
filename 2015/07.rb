require_relative 'util'

# --- Day 7: Some Assembly Required ---

# This year, Santa brought little Bobby Tables a set of wires and
# bitwise logic gates! Unfortunately, little Bobby is a little under
# the recommended age range, and he needs help assembling the circuit.

# Each wire has an identifier (some lowercase letters) and can carry a
# 16-bit signal (a number from 0 to 65535). A signal is provided to
# each wire by a gate, another wire, or some specific value. Each wire
# can only get a signal from one source, but can provide its signal to
# multiple destinations. A gate provides no signal until all of its
# inputs have a signal.

# The included instructions booklet describes how to connect the parts
# together: `x AND y -> z` means to connect wires `x` and `y` to an
# AND gate, and then connect its output to wire `z`.

# For example:

# - `123 -> x` means that the signal 123 is provided to wire `x`.
# - `x AND y -> z` means that the bitwise AND of wire `x` and wire `y`
#   is provided to wire `z`.
# - `p LSHIFT 2 -> q` means that the value from wire `p` is
#   left-shifted by 2 and then provided to wire `q`.
# - `NOT e -> f` means that the bitwise complement of the value from
#   wire `e` is provided to wire `f`.

# Other possible gates include `OR` (bitwise OR) and `RSHIFT`
# (right-shift). If, for some reason, you'd like to emulate the
# circuit instead, almost all programming languages (for example, C,
# JavaScript, or Python) provide operators for these gates.

# For example, here is a simple circuit:

#     123 -> x
#     456 -> y
#     x AND y -> d
#     x OR y -> e
#     x LSHIFT 2 -> f
#     y RSHIFT 2 -> g
#     NOT x -> h
#     NOT y -> i

# After it is run, these are the signals on the wires:

#     d: 72
#     e: 507
#     f: 492
#     g: 114
#     h: 65412
#     i: 65079
#     x: 123
#     y: 456

# In little Bobby's kit's instructions booklet (provided as your
# puzzle input), what signal is ultimately provided to wire a?

test_input = [
  '123 -> x',
  '456 -> y',
  'x AND y -> d',
  'x OR y -> e',
  'x LSHIFT 2 -> f',
  'y RSHIFT 2 -> g',
  'NOT x -> h',
  'NOT y -> i'
]
input = File.open('07.txt') { |f| f.readlines.map(&:chomp) }

def parse_arg(arg)
  if arg[/^\d+$/]
    arg.to_i
  else
    arg
  end
end

def parse(line)
  from, to = line.split(' -> ')
  ops = from.split(' ')
  case ops.length
  when 1 then [to, parse_arg(from)]
  when 2 then [to, :not, parse_arg(ops[1])]
  when 3 then [to, ops[1].downcase.to_sym, parse_arg(ops[0]), parse_arg(ops[2])]
  end
end

class Circuit
  def initialize(input)
    @cache = {}
    @wires = {}
    input.each do |line|
      to, *from = parse(line)
      @wires[to] = from
    end
  end

  def lookup(wire)
    return wire if wire.is_a?(Integer)
    return @cache[wire] if @cache[wire]
    op, *args = @wires[wire]
    out = case op
          when Integer then op
          when String then lookup(op)
          when :not then ~lookup(args[0]) & (2**16 - 1)
          when :and then lookup(args[0]) & lookup(args[1])
          when :or then lookup(args[0]) | lookup(args[1])
          when :lshift then lookup(args[0]) << lookup(args[1])
          when :rshift then lookup(args[0]) >> lookup(args[1])
          end
    @cache[wire] = out
    out
  end
end

def easy(input, wire)
  circuit = Circuit.new(input)
  circuit.lookup(wire)
end

assert(easy(test_input, 'd') == 72)
assert(easy(test_input, 'e') == 507)
assert(easy(test_input, 'f') == 492)
assert(easy(test_input, 'g') == 114)
assert(easy(test_input, 'h') == 65_412)
assert(easy(test_input, 'i') == 65_079)
assert(easy(test_input, 'x') == 123)
assert(easy(test_input, 'y') == 456)
puts("easy(input, 'a'): #{easy(input, 'a')}")

# --- Part Two ---

# Now, take the signal you got on wire a, override wire b to that
# signal, and reset the other wires (including wire a). What new
# signal is ultimately provided to wire a?

def hard(input, wire)
  signal = easy(input, 'a')
  i = input.find_index { |line| line[/-> b$/] }
  input[i] = "#{signal} -> b"

  circuit = Circuit.new(input)
  circuit.lookup(wire)
end

puts("hard(input, 'a'): #{hard(input, 'a')}")
