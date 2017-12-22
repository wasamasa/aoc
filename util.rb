def assert(condition)
  raise('assertion failed') unless condition
end

class Array
  def sum
    reduce(0, &:+)
  end
end

  def xreverse!(from, length)
    to = from + length
    (length / 2).times do |i|
      j = (to - i - 1) % size
      i = (from + i) % size
      x = at(i)
      y = at(j)
      self[i] = y
      self[j] = x
    end
  end
def explode(string)
  string.bytes.map(&:chr)
end
