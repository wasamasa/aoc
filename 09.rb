require_relative 'util'

# --- Day 9: Stream Processing ---

# A large stream blocks your path. According to the locals, it's not
# safe to cross the stream at the moment because it's full of
# garbage. You look down at the stream; rather than water, you
# discover that it's a stream of characters.

# You sit for a while and record part of the stream (your puzzle
# input). The characters represent groups - sequences that begin with
# `{` and end with `}`. Within a group, there are zero or more other
# things, separated by commas: either another group or garbage. Since
# groups can contain other groups, a `}` only closes the
# most-recently-opened unclosed group - that is, they are
# nestable. Your puzzle input represents a single, large group which
# itself contains many smaller ones.

# Sometimes, instead of a group, you will find garbage. Garbage begins
# with `<` and ends with `>`. Between those angle brackets, almost any
# character can appear, including `{` and `}`. Within garbage, `<` has
# no special meaning.

# In a futile attempt to clean up the garbage, some program has
# canceled some of the characters within it using `!`: inside garbage,
# any character that comes after `!` should be ignored, including `<`,
# `>`, and even another `!`.

# You don't see any characters that deviate from these rules. Outside
# garbage, you only find well-formed groups, and garbage always
# terminates according to the rules above.

# Here are some self-contained pieces of garbage:

# - `<>`, empty garbage.
# - `<random characters>`, garbage containing random characters.
# - `<<<<>`, because the extra < are ignored.
# - `<{!>}>`, because the first > is canceled.
# - `<!!>`, because the second ! is canceled, allowing the > to
#   terminate the garbage.
# - `<!!!>>`, because the second ! and the first > are canceled.
# - `<{o"i!a,<{i<a>`, which ends at the first >.

# Here are some examples of whole streams and the number of groups they contain:

# - `{}`, 1 group.
# - `{{{}}}`, 3 groups.
# - `{{},{}}`, also 3 groups.
# - `{{{},{},{{}}}}`, 6 groups.
# - `{<{},{},{{}}>}`, 1 group (which itself contains garbage).
# - `{<a>,<a>,<a>,<a>}`, 1 group.
# - `{{<a>},{<a>},{<a>},{<a>}}`, 5 groups.
# - `{{<!>},{<!>},{<!>},{<a>}}`, 2 groups (since all but the last >
#    are canceled).

# Your goal is to find the total score for all groups in your
# input. Each group is assigned a score which is one more than the
# score of the group that immediately contains it. (The outermost
# group gets a score of 1.)

# - `{}`, score of 1.
# - `{{{}}}`, score of 1 + 2 + 3 = 6.
# - `{{},{}}`, score of 1 + 2 + 2 = 5.
# - `{{{},{},{{}}}}`, score of 1 + 2 + 3 + 3 + 3 + 4 = 16.
# - `{<a>,<a>,<a>,<a>}`, score of 1.
# - `{{<ab>},{<ab>},{<ab>},{<ab>}}`, score of 1 + 2 + 2 + 2 + 2 = 9.
# - `{{<!!>},{<!!>},{<!!>},{<!!>}}`, score of 1 + 2 + 2 + 2 + 2 = 9.
# - `{{<a!>},{<a!>},{<a!>},{<ab>}}`, score of 1 + 2 = 3.

# What is the total score for all groups in your input?

class StreamTokenizer
  def initialize(input)
    @input = input
    @index = 0
    @tokens = []
  end

  def peek
    @input[@index]
  end

  def next!
    char = @input[@index]
    @index += 1 if char
    char
  end

  def tokenize
    loop do
      char = peek
      break unless char
      case char
      when '{' then @tokens << next!
      when '}' then @tokens << next!
      when '<' then tokenize_garbage
      when '>' then raise('unexpected garbage end')
      when ',' then next!
      end
    end
    @tokens
  end

  def tokenize_garbage
    token = ''
    loop do
      char = peek
      token += next!
      case char
      when '!' then token += next!
      when '>' then break
      end
    end
    @tokens << token
  end
end

class StreamParser
  def initialize(input)
    tokenizer = StreamTokenizer.new(input)
    @tokens = tokenizer.tokenize
    @index = 0
  end

  def peek
    @tokens[@index]
  end

  def next!
    token = @tokens[@index]
    @index += 1 if token
    token
  end

  def parse
    token = peek
    assert(token)
    case token
    when '{' then parse_group
    when '}' then raise('unexpected group end')
    when /^</ then parse_token
    end
  end

  def parse_group
    group = []
    next! # pop '{'
    while peek != '}'
      raise('EOF') unless peek
      group << parse
    end
    next! # pop '}'
    group
  end

  def parse_token
    token = next!
    token = token[1..-2]
    token.gsub(/!./, '')
  end
end

input = File.open('09.txt') { |f| f.read.chomp }

def tokenize(input)
  tokenizer = StreamTokenizer.new(input)
  tokenizer.tokenize
end

def parse(input)
  parser = StreamParser.new(input)
  parser.parse
end

def score_ast(ast, depth = 1)
  case ast
  when String then 0
  when Array
    if ast.empty?
      depth
    else
      depth + ast.map { |item| score_ast(item, depth + 1) }.sum
    end
  end
end

def easy(input)
  score_ast(parse(input))
end

assert(tokenize('<>') == ['<>'])
assert(parse('<>') == '')
assert(tokenize('<random characters>') == ['<random characters>'])
assert(parse('<random characters>') == 'random characters')
assert(tokenize('<<<<>') == ['<<<<>'])
assert(parse('<<<<>') == '<<<')
assert(tokenize('<{!>}>') == ['<{!>}>'])
assert(parse('<{!>}>') == '{}')
assert(tokenize('<!!>') == ['<!!>'])
assert(parse('<!!>') == '')
assert(tokenize('<!!!>>') == ['<!!!>>'])
assert(parse('<!!!>>') == '')
assert(tokenize('<{o"i!a,<{i<a>') == ['<{o"i!a,<{i<a>'])
assert(parse('<{o"i!a,<{i<a>') == '{o"i,<{i<a')

assert(tokenize('{}') == ['{', '}'])
assert(parse('{}') == [])
assert(tokenize('{{{}}}') == ['{', '{', '{', '}', '}', '}'])
assert(parse('{{{}}}') == [[[]]])
assert(tokenize('{{},{}}') == ['{', '{', '}', '{', '}', '}'])
assert(parse('{{},{}}') == [[], []])
assert(tokenize('{{{},{},{{}}}}') ==
       ['{', '{', '{', '}', '{', '}', '{', '{', '}', '}', '}', '}'])
assert(parse('{{{},{},{{}}}}') == [[[], [], [[]]]])
assert(tokenize('{<{},{},{{}}>}') == ['{', '<{},{},{{}}>', '}'])
assert(parse('{<{},{},{{}}>}') == ['{},{},{{}}'])
assert(tokenize('{<a>,<a>,<a>,<a>}') == ['{', '<a>', '<a>', '<a>', '<a>', '}'])
assert(parse('{<a>,<a>,<a>,<a>}') == ['a', 'a', 'a', 'a'])
assert(tokenize('{{<a>},{<a>},{<a>},{<a>}}') ==
       ['{', '{', '<a>', '}', '{', '<a>', '}', '{', '<a>', '}',
        '{', '<a>', '}', '}'])
assert(parse('{{<a>},{<a>},{<a>},{<a>}}') == [['a'], ['a'], ['a'], ['a']])
assert(tokenize('{{<!>},{<!>},{<!>},{<a>}}') ==
       ['{', '{', '<!>},{<!>},{<!>},{<a>', '}', '}'])
assert(parse('{{<!>},{<!>},{<!>},{<a>}}') == [['},{<},{<},{<a']])
assert(tokenize('{{<ab>},{<ab>},{<ab>},{<ab>}}') ==
       ['{', '{', '<ab>', '}', '{', '<ab>', '}', '{', '<ab>', '}',
        '{', '<ab>', '}', '}'])
assert(parse('{{<ab>},{<ab>},{<ab>},{<ab>}}') ==
       [['ab'], ['ab'], ['ab'], ['ab']])
assert(tokenize('{{<!!>},{<!!>},{<!!>},{<!!>}}') ==
       ['{', '{', '<!!>', '}', '{', '<!!>', '}', '{', '<!!>', '}',
        '{', '<!!>', '}', '}'])
assert(parse('{{<!!>},{<!!>},{<!!>},{<!!>}}') == [[''], [''], [''], ['']])
assert(tokenize('{{<a!>},{<a!>},{<a!>},{<ab>}}') ==
       ['{', '{', '<a!>},{<a!>},{<a!>},{<ab>', '}', '}'])
assert(parse('{{<a!>},{<a!>},{<a!>},{<ab>}}') == [['a},{<a},{<a},{<ab']])

assert(easy('{}') == 1)
assert(easy('{{{}}}') == 6)
assert(easy('{{},{}}') == 5)
assert(easy('{{{},{},{{}}}}') == 16)
assert(easy('{<a>,<a>,<a>,<a>}') == 1)
assert(easy('{{<ab>},{<ab>},{<ab>},{<ab>}}') == 9)
assert(easy('{{<!!>},{<!!>},{<!!>},{<!!>}}') == 9)
assert(easy('{{<a!>},{<a!>},{<a!>},{<ab>}}') == 3)

puts "easy(input): #{easy(input)}"

# --- Part Two ---

# Now, you're ready to remove the garbage.

# To prove you've removed it, you need to count all of the characters
# within the garbage. The leading and trailing `<` and `>` don't count,
# nor do any canceled characters or the `!` doing the canceling.

# - `<>`, 0 characters.
# - `<random characters>`, 17 characters.
# - `<<<<>`, 3 characters.
# - `<{!>}>`, 2 characters.
# - `<!!>`, 0 characters.
# - `<!!!>>`, 0 characters.
# - `<{o"i!a,<{i<a>`, 10 characters.

# How many non-canceled characters are within the garbage in your
# puzzle input?

def garbage_walk(ast)
  case ast
  when String
    ast.length
  when Array
    ast.map { |item| garbage_walk(item) }.sum
  end
end

def hard(input)
  garbage_walk(parse(input))
end

assert(hard('<>') == 0)
assert(hard('<random characters>') == 17)
assert(hard('<<<<>') == 3)
assert(hard('<{!>}>') == 2)
assert(hard('<!!>') == 0)
assert(hard('<!!!>>') == 0)
assert(hard('<{o"i!a,<{i<a>') == 10)

assert(hard('{}') == 0)
assert(hard('{<123>}') == 3)
assert(hard('{<123>,<456>}') == 6)
assert(hard('{<123>,<456>,{<789>}}') == 9)

puts "hard(input): #{hard(input)}"
