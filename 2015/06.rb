require_relative 'util'

# --- Day 6: Probably a Fire Hazard ---

# Because your neighbors keep defeating you in the holiday house
# decorating contest year after year, you've decided to deploy one
# million lights in a 1000x1000 grid.

# Furthermore, because you've been especially nice this year, Santa
# has mailed you instructions on how to display the ideal lighting
# configuration.

# Lights in your grid are numbered from 0 to 999 in each direction;
# the lights at each corner are at `0,0`, `0,999`, `999,999`, and
# `999,0`. The instructions include whether to turn on, turn off, or
# toggle various inclusive ranges given as coordinate pairs. Each
# coordinate pair represents opposite corners of a rectangle,
# inclusive; a coordinate pair like `0,0 through 2,2` therefore refers
# to 9 lights in a `3x3` square. The lights all start turned off.

# To defeat your neighbors this year, all you have to do is set up
# your lights by doing the instructions Santa sent you in order.

# For example:

# - `turn on 0,0 through 999,999` would turn on (or leave on) every
#   light.
# - `toggle 0,0 through 999,0` would toggle the first line of 1000
#   lights, turning off the ones that were on, and turning on the ones
#   that were off.
# - `turn off 499,499 through 500,500` would turn off (or leave off)
#   the middle four lights.

# After following the instructions, how many lights are lit?

input = File.open('06.txt') { |f| f.readlines.map(&:chomp) }

class Lights
  def initialize
    @grid = Array.new(1000) { Array.new(1000, false) }
  end

  def change(x1, y1, x2, y2)
    x = x1
    while x <= x2
      y = y1
      while y <= y2
        @grid[x][y] = yield(@grid[x][y])
        y += 1
      end
      x += 1
    end
  end

  def count
    lights = 0
    @grid.each do |line|
      line.each do |light|
        lights += 1 if light
      end
    end
    lights
  end
end

def easy(lines)
  lights = Lights.new
  lines.each do |line|
    parts = line.split
    x1, y1 = parts[-3].split(',').map(&:to_i)
    x2, y2 = parts[-1].split(',').map(&:to_i)
    case line
    when /^turn on/ then lights.change(x1, y1, x2, y2) { true }
    when /^turn off/ then lights.change(x1, y1, x2, y2) { false }
    when /^toggle/ then lights.change(x1, y1, x2, y2, &:!)
    end
  end
  lights.count
end

assert(easy(['turn on 0,0 through 999,999']) == 1_000_000)
assert(easy(['turn on 0,0 through 999,999',
             'toggle 0,0 through 999,0']) == 999_000)
assert(easy(['turn on 0,0 through 999,999',
             'toggle 0,0 through 999,0',
             'turn off 499,499 through 500,500']) == 998_996)

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# You just finish implementing your winning light pattern when you
# realize you mistranslated Santa's message from Ancient Nordic
# Elvish.

# The light grid you bought actually has individual brightness
# controls; each light can have a brightness of zero or more. The
# lights all start at zero.

# The phrase turn on actually means that you should increase the
# brightness of those lights by 1.

# The phrase turn off actually means that you should decrease the
# brightness of those lights by 1, to a minimum of zero.

# The phrase toggle actually means that you should increase the
# brightness of those lights by 2.

# What is the total brightness of all lights combined after following
# Santa's instructions?

# For example:

# - `turn on 0,0 through 0,0` would increase the total brightness by 1.
# - `toggle 0,0 through 999,999` would increase the total brightness by
#   2000000.

class BrightLights
  def initialize
    @grid = Array.new(1000) { Array.new(1000, 0) }
  end

  def change(x1, y1, x2, y2)
    x = x1
    while x <= x2
      y = y1
      while y <= y2
        brightness = @grid[x][y]
        @grid[x][y] = [0, brightness + yield(brightness)].max
        y += 1
      end
      x += 1
    end
  end

  def count
    brightness = 0
    @grid.each do |line|
      line.each do |light|
        brightness += light
      end
    end
    brightness
  end
end

def hard(lines)
  lights = BrightLights.new
  lines.each do |line|
    parts = line.split
    x1, y1 = parts[-3].split(',').map(&:to_i)
    x2, y2 = parts[-1].split(',').map(&:to_i)
    case line
    when /^turn on/ then lights.change(x1, y1, x2, y2) { 1 }
    when /^turn off/ then lights.change(x1, y1, x2, y2) { -1 }
    when /^toggle/ then lights.change(x1, y1, x2, y2) { 2 }
    end
  end
  lights.count
end

assert(hard(['turn on 0,0 through 0,0']) == 1)
assert(hard(['turn on 0,0 through 0,0',
             'toggle 0,0 through 999,999']) == 2_000_001)
puts "hard(input): #{hard(input)}"
