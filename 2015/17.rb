require_relative 'util'

# --- Day 17: No Such Thing as Too Much ---

# The elves bought too much eggnog again - 150 liters this time. To
# fit it all into your refrigerator, you'll need to move it into
# smaller containers. You take an inventory of the capacities of the
# available containers.

# For example, suppose you have containers of size 20, 15, 10, 5, and
# 5 liters. If you need to store 25 liters, there are four ways to do
# it:

# - 15 and 10
# - 20 and 5 (the first 5)
# - 20 and 5 (the second 5)
# - 15, 5, and 5

# Filling all containers entirely, how many different combinations of
# containers can exactly fit all 150 liters of eggnog?

input = File.open('17.txt') { |f| f.readlines.map(&:to_i) }
test_input = [20, 15, 10, 5, 5]

def easy(input, amount)
  count = 0
  (2..input.length).each do |i|
    count += input.combination(i).select { |c| c.sum == amount }.length
  end
  count
end

assert(easy(test_input, 25) == 4)
puts "easy(input, 150): #{easy(input, 150)}"

# --- Part Two ---

# While playing with all the containers in the kitchen, another load
# of eggnog arrives! The shipping and receiving department is
# requesting as many containers as you can spare.

# Find the minimum number of containers that can exactly fit all 150
# liters of eggnog. How many different ways can you fill that number
# of containers and still hold exactly 150 litres?

# In the example above, the minimum number of containers was
# two. There were three ways to use that many containers, and so the
# answer there would be 3.

def hard(input, amount)
  solutions = {}
  (2..input.length).each do |i|
    count = input.combination(i).select { |c| c.sum == amount }.length
    solutions[i] = count unless count.zero?
  end
  min_containers = solutions.keys.min
  solutions[min_containers]
end

assert(hard(test_input, 25) == 3)
puts "hard(input, 150): #{hard(input, 150)}"
