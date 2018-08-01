require_relative 'util'
require 'set'

# --- Day 9: All in a Single Night ---

# Every year, Santa manages to deliver all of his presents in a single
# night.

# This year, however, he has some new locations to visit; his elves
# have provided him the distances between every pair of locations. He
# can start and end at any two (different) locations he wants, but he
# must visit each location exactly once. What is the shortest distance
# he can travel to achieve this?

# For example, given the following distances:

#     London to Dublin = 464
#     London to Belfast = 518
#     Dublin to Belfast = 141

# The possible routes are therefore:

#     Dublin -> London -> Belfast = 982
#     London -> Dublin -> Belfast = 605
#     London -> Belfast -> Dublin = 659
#     Dublin -> Belfast -> London = 659
#     Belfast -> Dublin -> London = 605
#     Belfast -> London -> Dublin = 982

# The shortest of these is London -> Dublin -> Belfast = 605, and so
# the answer is 605 in this example.

# What is the distance of the shortest route?

input = File.open('09.txt') { |f| f.readlines.map(&:chomp) }
test_input = ['London to Dublin = 464',
              'London to Belfast = 518',
              'Dublin to Belfast = 141']

class TSP
  def initialize(input)
    @cities = Set.new
    @routes = {}
    input.each do |line|
      from, _, to, _, distance = line.split(' ')
      @cities << from
      @cities << to
      @routes[[from, to]] = distance.to_i
      @routes[[to, from]] = distance.to_i
    end
  end

  def distance(route)
    result = 0
    route.each_cons(2) { |xy| result += @routes[xy] }
    result
  end

  def shortest
    @cities.to_a.permutation.min_by { |route| distance(route) }
  end
end

def easy(input)
  tsp = TSP.new(input)
  tsp.distance(tsp.shortest)
end

assert(easy(test_input) == 605)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# The next year, just to show off, Santa decides to take the route
# with the longest distance instead.

# He can still start and end at any two (different) locations he
# wants, and he still must visit each location exactly once.

# For example, given the distances above, the longest route would be
# 982 via (for example) Dublin -> London -> Belfast.

# What is the distance of the longest route?

class TSP2 < TSP
  def longest
    @cities.to_a.permutation.max_by { |route| distance(route) }
  end
end

def hard(input)
  tsp = TSP2.new(input)
  tsp.distance(tsp.longest)
end

assert(hard(test_input) == 982)
puts "hard(input): #{hard(input)}"
