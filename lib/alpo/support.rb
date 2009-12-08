module Alpo
# TODO - factor this out into 'util' or some such
#
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

  def key_for(key)
    return key if Numeric===key
    key.to_s =~ %r/^\d+$/ ? Integer(key) : key
  end

  def underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end
