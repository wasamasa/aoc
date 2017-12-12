require_relative 'util'
require 'set'

# --- Day 12: Digital Plumber ---

# Walking along the memory banks of the stream, you find a small
# village that is experiencing a little confusion: some programs can't
# communicate with each other.

# Programs in this village communicate using a fixed system of
# pipes. Messages are passed between programs using these pipes, but
# most programs aren't connected to each other directly. Instead,
# programs pass messages between each other until the message reaches
# the intended recipient.

# For some reason, though, some of these messages aren't ever reaching
# their intended recipient, and the programs suspect that some pipes
# are missing. They would like you to investigate.

# You walk through the village and record the ID of each program and
# the IDs with which it can communicate directly (your puzzle
# input). Each program has one or more programs with which it can
# communicate, and these pipes are bidirectional; if 8 says it can
# communicate with 11, then 11 will say it can communicate with 8.

# You need to figure out how many programs are in the group that
# contains program ID 0.

# For example, suppose you go door-to-door like a travelling salesman
# and record the following list:

#     0 <-> 2
#     1 <-> 1
#     2 <-> 0, 3, 4
#     3 <-> 2, 4
#     4 <-> 2, 3, 6
#     5 <-> 6
#     6 <-> 4, 5

# In this example, the following programs are in the group that
# contains program ID 0:

# - Program 0 by definition.
# - Program 2, directly connected to program 0.
# - Program 3 via program 2.
# - Program 4 via program 2.
# - Program 5 via programs 6, then 4, then 2.
# - Program 6 via programs 4, then 2.

# Therefore, a total of 6 programs are in this group; all but program
# 1, which has a pipe that connects it to itself.

# How many programs are in the group that contains program ID 0?

class Graph
  def initialize
    @vertices = {}
  end

  def self.from(input)
    graph = Graph.new
    input.each { |name, _| graph.add_vertex(Vertex.new(name)) }
    input.each do |from, neighbors|
      neighbors.each do |to|
        graph.link(from, to)
        graph.link(to, from)
      end
    end
    graph
  end

  def add_vertex(vertex)
    @vertices[vertex.name] = vertex
  end

  def fetch(name)
    @vertices[name]
  end

  def link(from, to)
    fetch(from).neighbors << to
    fetch(to).neighbors << from
  end

  def vertices
    @vertices.values
  end
end

class Vertex
  attr_accessor :name, :neighbors

  def initialize(name)
    @name = name
    @neighbors = Set.new
  end
end

def parse(line)
  node, rest = line.split(' <-> ')
  neighbors = rest.split(', ').map(&:to_i)
  [node.to_i, neighbors]
end

test_input = [
  '0 <-> 2',
  '1 <-> 1',
  '2 <-> 0, 3, 4',
  '3 <-> 2, 4',
  '4 <-> 2, 3, 6',
  '5 <-> 6',
  '6 <-> 4, 5'
].map { |line| parse(line) }

input = File.open('12.txt') { |f| f.readlines.map { |line| parse(line.chomp) } }

def graph_walk(graph, start, seen = Set.new)
  seen << start
  start.neighbors.each do |neighbor|
    vertex = graph.fetch(neighbor)
    graph_walk(graph, vertex, seen) unless seen.include?(vertex)
  end
  seen
end

def easy(input)
  graph = Graph.from(input)
  seen = graph_walk(graph, graph.fetch(0))
  seen.length
end

assert(easy(test_input) == 6)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# There are more programs than just the ones in the group containing
# program ID 0. The rest of them have no way of reaching that group,
# and still might have no way of reaching each other.

# A group is a collection of programs that can all communicate via
# pipes either directly or indirectly. The programs you identified
# just a moment ago are all part of the same group. Now, they would
# like you to determine the total number of groups.

# In the example above, there were 2 groups: one consisting of
# programs 0,2,3,4,5,6, and the other consisting solely of program 1.

# How many groups are there in total?

def hard(input)
  graph = Graph.from(input)
  components = []
  vertices = Set.new(graph.vertices)
  until vertices.empty?
    start = vertices.first
    component = graph_walk(graph, start)
    components << component
    vertices = vertices.difference(component)
  end
  components.length
end

assert(hard(test_input) == 2)
puts "hard(input): #{hard(input)}"
