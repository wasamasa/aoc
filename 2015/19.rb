require_relative 'util'
require 'set'

# --- Day 19: Medicine for Rudolph ---

# Rudolph the Red-Nosed Reindeer is sick! His nose isn't shining very
# brightly, and he needs medicine.

# Red-Nosed Reindeer biology isn't similar to regular reindeer
# biology; Rudolph is going to need custom-made
# medicine. Unfortunately, Red-Nosed Reindeer chemistry isn't similar
# to regular reindeer chemistry, either.

# The North Pole is equipped with a Red-Nosed Reindeer nuclear
# fusion/fission plant, capable of constructing any Red-Nosed Reindeer
# molecule you need. It works by starting with some input molecule and
# then doing a series of replacements, one per step, until it has the
# right molecule.

# However, the machine has to be calibrated before it can be
# used. Calibration involves determining the number of molecules that
# can be generated in one step from a given starting point.

# For example, imagine a simpler machine that supports only the
# following replacements:

#     H => HO
#     H => OH
#     O => HH

# Given the replacements above and starting with HOH, the following
# molecules could be generated:

# - `HOOH` (via `H => HO` on the first H).
# - `HOHO` (via `H => HO` on the second H).
# - `OHOH` (via `H => OH` on the first H).
# - `HOOH` (via `H => OH` on the second H).
# - `HHHH` (via `O => HH`).

# So, in the example above, there are 4 distinct molecules (not five,
# because `HOOH` appears twice) after one replacement from
# `HOH`. Santa's favorite molecule, `HOHOHO`, can become 7 distinct
# molecules (over nine replacements: six from H, and three from O).

# The machine replaces without regard for the surrounding
# characters. For example, given the string `H2O`, the transition `H
# => OO` would result in `OO2O`.

# Your puzzle input describes all of the possible replacements and, at
# the bottom, the medicine molecule for which you need to calibrate
# the machine. How many distinct molecules can be created after all
# the different ways you can do one replacement on the medicine
# molecule?

input = File.open('19.txt') { |f| f.readlines.map(&:chomp) }
rules = input.select { |line| line[/=>/] }.map { |line| line.split(' => ') }
source = input[-1]

test_rules = [%w[H HO], %w[H OH], %w[O HH]]

def patch(source, i, from, to)
  a = source[0...i]
  b = source[(i + from.length)..-1]
  a + to + b
end

assert(patch('foobarXqux', 6, 'x', 'baz') == 'foobarbazqux')

def easy(source, rules)
  molecules = Set.new
  (0...source.length).each do |i|
    s = source[i..-1]
    rules.each do |from, to|
      molecules << patch(source, i, from, to) if s.start_with?(from)
    end
  end
  molecules.length
end

assert(easy('HOH', test_rules) == 4)
puts "easy(source, rules): #{easy(source, rules)}"

# --- Part Two ---

# Now that the machine is calibrated, you're ready to begin molecule
# fabrication.

# Molecule fabrication always begins with just a single electron, e,
# and applying replacements one at a time, just like the ones during
# calibration.

# For example, suppose you have the following replacements:

#     e => H
#     e => O
#     H => HO
#     H => OH
#     O => HH

# If you'd like to make HOH, you start with e, and then make the
# following replacements:

# - `e => O` to get `O`
# - `O => HH` to get `HH`
# - `H => OH` (on the second H) to get `HOH`

# So, you could make `HOH` after 3 steps. Santa's favorite molecule,
# `HOHOHO`, can be made in 6 steps.

# How long will it take to make the medicine? Given the available
# replacements and the medicine molecule in your puzzle input, what is
# the fewest number of steps to go from e to the medicine molecule?

test_rules += [%w[e H], %w[e O]]

def hard(molecule, rules)
  replacements = rules.sort_by { |_, t| t.length }.reverse
  steps = 0
  while molecule != 'e'
    from, to = replacements.find { |_, t| molecule.index(t) }
    raise 'oof' unless to
    i = molecule.index(to)
    molecule = patch(molecule, i, to, from)
    steps += 1
  end
  steps
end

assert(hard('HOH', test_rules) == 3)
assert(hard('HOHOHO', test_rules) == 6)
puts "hard(source, rules): #{hard(source, rules)}"
