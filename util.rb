def assert(condition)
  raise('assertion failed') unless condition
end

class Array
  def sum
    reduce(0, &:+)
  end
end

def explode(string)
  string.bytes.map(&:chr)
end
