module Alpo
  def normalized_hash(hash = {})
    HashWithIndifferentAccess.new.update(hash)
  end
  alias_method 'hash_for', 'normalized_hash'

  def depth_first_each(enumerable, path = [], accum = [], &block)
    Alpo.each_pair(enumerable) do |key, val|
      path.push(key)
      if val.is_a?(Hash) or val.is_a?(Array)
        Alpo.depth_first_each(val, path, accum) # recurse
      else
        accum << [path.dup, val]
      end
      path.pop()
    end
    if block
      accum.each{|keys, val| block.call(keys, val)}
    else
      [path, accum]
    end
  end

  def each_pair(enumerable, *args, &block)
    case enumerable
      when Hash
        enumerable.each_pair(*args, &block)
      when Array
        enumerable.each_with_index(*args) do |val, key|
          block.call(key, val)
        end
      else
        enumerable.each_pair(*args, &block)
    end
  end
end
