require_relative 'util'

# --- Day 7: Recursive Circus ---

# Wandering further through the circuits of the computer, you come
# upon a tower of programs that have gotten themselves into a bit of
# trouble. A recursive algorithm has gotten out of hand, and now
# they're balanced precariously in a large tower.

# One program at the bottom supports the entire tower. It's holding a
# large disc, and on the disc are balanced several more sub-towers. At
# the bottom of these sub-towers, standing on the bottom disc, are
# other programs, each holding their own disc, and so on. At the very
# tops of these sub-sub-sub-...-towers, many programs stand simply
# keeping the disc below them balanced but with no disc of their own.

# You offer to help, but first you need to understand the structure of
# these towers. You ask each program to yell out their name, their
# weight, and (if they're holding a disc) the names of the programs
# immediately above them balancing on that disc. You write this
# information down (your puzzle input). Unfortunately, in their panic,
# they don't do this in an orderly fashion; by the time you're done,
# you're not sure which program gave which information.

# For example, if your list is the following:

#     pbga (66)
#     xhth (57)
#     ebii (61)
#     havc (66)
#     ktlj (57)
#     fwft (72) -> ktlj, cntj, xhth
#     qoyq (66)
#     padx (45) -> pbga, havc, qoyq
#     tknk (41) -> ugml, padx, fwft
#     jptl (61)
#     ugml (68) -> gyxo, ebii, jptl
#     gyxo (61)
#     cntj (57)

# ...then you would be able to recreate the structure of the towers
# that looks like this:

#                     gyxo
#                   /
#              ugml - ebii
#            /      \
#           |         jptl
#           |
#           |         pbga
#          /        /
#     tknk --- padx - havc
#          \        \
#           |         qoyq
#           |
#           |         ktlj
#            \      /
#              fwft - cntj
#                   \
#                     xhth

# In this example, tknk is at the bottom of the tower (the bottom
# program), and is holding up ugml, padx, and fwft. Those programs
# are, in turn, holding up other programs; in this example, none of
# those programs are holding up any other programs, and are all the
# tops of their own towers. (The actual tower balancing in front of
# you is much larger.)

# Before you're ready to help them, you need to make sure your
# information is correct. What is the name of the bottom program?

class Tree
  attr_accessor :root, :nodes

  def initialize
    @root = nil
    @nodes = {}
  end

  def link_nodes!(input)
    input.each do |name, weight, children_names|
      node = TreeNode.new(name, weight, children_names)
      @nodes[name] = node
    end

    @nodes.values.each do |node|
      next unless node.children_names
      children = nodes.values_at(*node.children_names)
      children.each { |child| node.link!(child) }
      node.children_names = nil
    end
  end

  def self.from(input)
    tree = new
    tree.link_nodes!(input)
    tree.root = tree.nodes.values.sample
    tree.root = tree.root.parent while tree.root.parent
    tree
  end
end

class TreeNode
  attr_accessor :name, :weight, :children_names, :parent, :children

  def initialize(name, weight, children_names)
    @name = name
    @weight = weight
    @children_names = children_names
    @parent = nil
    @children = nil
  end

  def to_s
    if @children
      representations = @children.map(&:to_s)
      "<#{@name} (#{@weight}) [#{total_weight}]: #{representations.join(', ')}>"
    else
      "<#{@name} (#{@weight}) [#{total_weight}]>"
    end
  end

  def link!(child)
    @children ||= []
    @children << child
    child.parent = self
  end

  def total_weight
    return @weight unless @children
    @weight + @children.map(&:total_weight).sum
  end

  def balanced?
    return true unless children
    weight = children[0].total_weight
    children.drop(1).all? { |child| child.total_weight == weight }
  end

  def find_balanced(root = self)
    return root if root.balanced?
    root.children.each do |child|
      result = child.find_balanced
      return result if result
    end
    nil
  end
end

def parse(line)
  info, children = line.split(' -> ')
  _, name, weight = info.match(/^([a-z]+) \(([0-9]+)\)/).to_a
  children = children.split(', ') if children
  [name, weight.to_i, children]
end

input = File.open('07.txt') { |f| f.readlines.map { |line| parse(line.chomp) } }

test_input = [
  'pbga (66)',
  'xhth (57)',
  'ebii (61)',
  'havc (66)',
  'ktlj (57)',
  'fwft (72) -> ktlj, cntj, xhth',
  'qoyq (66)',
  'padx (45) -> pbga, havc, qoyq',
  'tknk (41) -> ugml, padx, fwft',
  'jptl (61)',
  'ugml (68) -> gyxo, ebii, jptl',
  'gyxo (61)',
  'cntj (57)'
].map { |line| parse(line) }

def easy(input)
  tree = Tree.from(input)
  tree.root.name
end

test_tree = Tree.from(test_input)
assert(test_tree.root.name == 'tknk')
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# The programs explain the situation: they can't get down. Rather,
# they could get down, if they weren't expending all of their energy
# trying to keep the tower balanced. Apparently, one program has the
# wrong weight, and until it's fixed, they're stuck here.

# For any program holding a disc, each program standing on that disc
# forms a sub-tower. Each of those sub-towers are supposed to be the
# same weight, or the disc itself isn't balanced. The weight of a
# tower is the sum of the weights of the programs in that tower.

# In the example above, this means that for ugml's disc to be
# balanced, gyxo, ebii, and jptl must all have the same weight, and
# they do: 61.

# However, for tknk to be balanced, each of the programs standing on
# its disc and all programs above it must each match. This means that
# the following sums must all be the same:

# - ugml + (gyxo + ebii + jptl) = 68 + (61 + 61 + 61) = 251
# - padx + (pbga + havc + qoyq) = 45 + (66 + 66 + 66) = 243
# - fwft + (ktlj + cntj + xhth) = 72 + (57 + 57 + 57) = 243

# As you can see, tknk's disc is unbalanced: ugml's stack is heavier
# than the other two. Even though the nodes above ugml are balanced,
# ugml itself is too heavy: it needs to be 8 units lighter for its
# stack to weigh 243 and keep the towers balanced. If this change were
# made, its weight would be 60.

# Given that exactly one program is the wrong weight, what would its
# weight need to be to balance the entire tower?

def outlier(items)
  candidates = items.uniq
  return [] unless candidates.length == 2
  a, b = candidates
  outlier, other = items.count(a) == 1 ? [a, b] : [b, a]
  difference = outlier - other
  index = items.find_index(outlier)
  [outlier, difference, index]
end

def hard(input)
  tree = Tree.from(input)
  children = tree.root.find_balanced.parent.children
  candidate = nil
  difference = 0

  loop do
    total_weights = children.map(&:total_weight)
    outlier_data = outlier(total_weights).drop(1)
    break if outlier_data.empty?
    difference, index = outlier_data
    candidate = children[index]
    children = candidate.children
  end

  candidate.weight - difference
end

assert(test_tree.nodes['gyxo'].total_weight == test_tree.nodes['gyxo'].weight)
assert(test_tree.nodes['ebii'].total_weight == test_tree.nodes['ebii'].weight)
assert(test_tree.nodes['jptl'].total_weight == test_tree.nodes['jptl'].weight)
assert(test_tree.nodes['ugml'].total_weight != test_tree.nodes['ugml'].weight)

assert(test_tree.nodes['ugml'].total_weight == 251)
assert(test_tree.nodes['padx'].total_weight == 243)
assert(test_tree.nodes['fwft'].total_weight == 243)

assert(test_tree.nodes['tknk'].total_weight ==
       (test_tree.nodes['tknk'].weight +
        test_tree.nodes['ugml'].total_weight +
        test_tree.nodes['padx'].total_weight +
        test_tree.nodes['fwft'].total_weight))

assert(!test_tree.root.balanced?)
assert(test_tree.root.children[0].balanced?)
assert(test_tree.root.children[1].balanced?)
assert(test_tree.root.children[2].balanced?)
assert(test_tree.root.find_balanced != test_tree.root)
assert(test_tree.root.find_balanced == test_tree.root.children[0])

candidates = test_tree.root.find_balanced.parent.children
total_weights = candidates.map(&:total_weight)
outlier, difference, index = outlier(total_weights)
assert(outlier == 251)
assert(difference == 8)
assert(index.zero?)
candidates[index].weight -= difference
assert(test_tree.root.balanced?)

puts "hard(input): #{hard(input)}"
