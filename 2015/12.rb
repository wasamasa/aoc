require_relative 'util'

# --- Day 12: JSAbacusFramework.io ---

# Santa's Accounting-Elves need help balancing the books after a
# recent order. Unfortunately, their accounting software uses a
# peculiar storage format. That's where you come in.

# They have a JSON document which contains a variety of things: arrays
# (`[1,2,3]`), objects (`{"a":1, "b":2}`), numbers, and strings. Your
# first job is to simply find all of the numbers throughout the
# document and add them together.

# For example:

# - `[1,2,3]` and `{"a":2,"b":4}` both have a sum of 6.
# - `[[[3]]]` and `{"a":{"b":4},"c":-1}` both have a sum of 3.
# - `{"a":[-1,1]}` and `[-1,{"a":1}]` both have a sum of 0.
# - `[]` and `{}` both have a sum of 0.

# You will not encounter any strings containing numbers.

# What is the sum of all numbers in the document?

input = File.open('12.txt') { |f| f.read.chomp }

def easy(input)
  input.scan(/-?\d+/).map(&:to_i).sum
end

assert(easy('[1,2,3]') == 6)
assert(easy('{"a":2,"b":4}') == 6)
assert(easy('[[[3]]]') == 3)
assert(easy('{"a":{"b":4},"c":-1}') == 3)
assert(easy('{"a":[-1,1]}') == 0)
assert(easy('[-1,{"a":1}]') == 0)
assert(easy('[]') == 0)
assert(easy('{}') == 0)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# Uh oh - the Accounting-Elves have realized that they double-counted
# everything red.

# Ignore any object (and all of its children) which has any property
# with the value "red". Do this only for objects (`{...}`), not arrays
# (`[...]`).

# - `[1,2,3]` still has a sum of 6.
# - `[1,{"c":"red","b":2},3]` now has a sum of 4, because the middle
#   object is ignored.
# - `{"d":"red","e":[1,2,3,4],"f":5}` now has a sum of 0, because the
#   entire structure is ignored.
# - `[1,"red",5]` has a sum of 6, because "red" in an array has no
#   effect.

require 'json'

def json_walk(js, &block)
  case js
  when Array then js.each { |j| json_walk(j, &block) }
  when Hash
    js.each { |_, v| json_walk(v, &block) } unless js.values.include?('red')
  else yield(js)
  end
end

def hard(input)
  sum = 0
  js = JSON.parse(input)
  json_walk(js) { |j| sum += j if j.is_a?(Integer) }
  sum
end

assert(hard('[1,2,3]') == 6)
assert(hard('[1,{"c":"red","b":2},3]') == 4)
assert(hard('{"d":"red","e":[1,2,3,4],"f":5}') == 0)
assert(hard('[1,"red",5]') == 6)
puts "hard(input): #{hard(input)}"
