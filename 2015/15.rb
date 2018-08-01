require_relative 'util'

# --- Day 15: Science for Hungry People ---

# Today, you set out on the task of perfecting your milk-dunking
# cookie recipe. All you have to do is find the right balance of
# ingredients.

# Your recipe leaves room for exactly 100 teaspoons of
# ingredients. You make a list of the remaining ingredients you could
# use to finish the recipe (your puzzle input) and their properties
# per teaspoon:

# - capacity (how well it helps the cookie absorb milk)
# - durability (how well it keeps the cookie intact when full of milk)
# - flavor (how tasty it makes the cookie)
# - texture (how it improves the feel of the cookie)
# - calories (how many calories it adds to the cookie)

# You can only measure ingredients in whole-teaspoon amounts
# accurately, and you have to be accurate so you can reproduce your
# results in the future. The total score of a cookie can be found by
# adding up each of the properties (negative totals become 0) and then
# multiplying together everything except calories.

# For instance, suppose you have these two ingredients:

# - Butterscotch: capacity -1, durability -2, flavor 6, texture 3,
#   calories 8
# - Cinnamon: capacity 2, durability 3, flavor -2, texture -1,
#   calories 3

# Then, choosing to use 44 teaspoons of butterscotch and 56 teaspoons
# of cinnamon (because the amounts of each ingredient must add up to
# 100) would result in a cookie with the following properties:

# - A capacity of 44*-1 + 56*2 = 68
# - A durability of 44*-2 + 56*3 = 80
# - A flavor of 44*6 + 56*-2 = 152
# - A texture of 44*3 + 56*-1 = 76

# Multiplying these together (68 * 80 * 152 * 76, ignoring calories
# for now) results in a total score of 62842880, which happens to be
# the best score possible given these ingredients. If any properties
# had produced a negative total, it would have instead become zero,
# causing the whole score to multiply to zero.

# Given the ingredients in your kitchen and their properties, what is
# the total score of the highest-scoring cookie you can make?

input = File.open('15.txt') { |f| f.readlines.map(&:chomp) }
test_input = [
  'Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8',
  'Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3'
]

def parse(line)
  line.scan(/-?\d+/).map(&:to_i)
end

def score(counts, ingredients)
  props = []
  4.times do |i|
    sum = 0
    counts.each_with_index do |count, j|
      sum += count * ingredients[j][i]
    end
    props << [sum, 0].max
  end
  props.reduce(1, &:*)
end

assert(score([44, 56], [[-1, -2, 6, 3], [2, 3, -2, -1]]) == 62_842_880)

# I couldn't figure out how to do this generically, so it's somewhat
# hardcoded

def easy(input)
  sum = 100
  ingredients = input.map { |line| parse(line)[0..-2] }
  max = 0
  (0..sum).each do |i|
    (0..(sum - i)).each do |j|
      (0..(sum - i - j)).each do |k|
        l = sum - i - j - k
        score = score([i, j, k, l], ingredients)
        max = [score, max].max
      end
    end
  end
  max
end

puts "easy(input): #{easy(input)}"

def calories_score(counts, calories)
  sum = 0
  counts.each_with_index do |count, i|
    sum += count * calories[i]
  end
  sum
end

assert(calories_score([40, 60], [8, 3]) == 500)

def hard(input)
  sum = 100
  ingredients = input.map { |line| parse(line)[0..-2] }
  calories = input.map { |line| parse(line)[-1] }
  max = 0
  (0..sum).each do |i|
    (0..(sum - i)).each do |j|
      (0..(sum - i - j)).each do |k|
        l = sum - i - j - k
        score = score([i, j, k, l], ingredients)
        next unless calories_score([i, j, k, l], calories) == 500
        max = [score, max].max
      end
    end
  end
  max
end

puts "hard(input): #{hard(input)}"
