module Alpo
  class Map < ::Map
    def convert_value(value)
      return value.to_alpo if value.respond_to?(:to_alpo)
      super
    end

    def get(*keys)
      keys = keys.flatten
      return self[keys.first] if keys.size <= 1
      keys, key = keys[0..-2], keys[-1]
      collection = self
      keys.each do |k|
        k = key_for(k)
        collection = collection[k]
        return collection unless collection.respond_to?('[]')
      end
      collection[key_for(key)]
    end

    def has?(*keys)
      keys = keys.flatten
      collection = self
      return collection_has_key?(collection, keys.first) if keys.size <= 1
      keys, key = keys[0..-2], keys[-1]
      keys.each do |k|
        k = key_for(k)
        collection = collection[k]
        return collection unless collection.respond_to?('[]')
      end
      return false unless(collection.is_a?(Hash) or collection.is_a?(Array))
      collection_has_key?(collection, key_for(key))
    end

    def collection_has_key?(collection, key)
      case collection
        when Hash
          collection.has_key?(key)
        when Array
          return false unless key
          (0...collection.size).include?(Integer(key))
      end
    end

    def set(*args)
      if args.size == 1 and args.first.is_a?(Hash)
        options = args.shift
      else
        options = {}
        value = args.pop
        keys = args
        options[keys] = value
      end

      options.each do |keys, value|
        keys = Array(keys).flatten

        collection = self
        if keys.size <= 1
          collection[keys.first] = value
          next
        end

        key = nil

        keys.each_cons(2) do |a, b|
          a, b = key_for(a), key_for(b)

          case b
            when Numeric
              collection[a] ||= []
              raise(IndexError, "(#{ collection.inspect })[#{ a.inspect }]=#{ value.inspect }") unless collection[a].is_a?(Array)

            when String, Symbol
              collection[a] ||= {}
              raise(IndexError, "(#{ collection.inspect })[#{ a.inspect }]=#{ value.inspect }") unless collection[a].is_a?(Hash)
          end
          collection = collection[a]
          key = b
        end

        collection[key] = value
      end

      return options.values
    end

    def key_for(key)
      return key if Numeric===key
      key.to_s =~ %r/^\d+$/ ? Integer(key) : key
    end

    def Map.depth_first_each(enumerable, path = [], accum = [], &block)
      Map.each_pair(enumerable) do |key, val|
        path.push(key)
        if((val.is_a?(Hash) or val.is_a?(Array)) and not val.empty?)
          Map.depth_first_each(val, path, accum)
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

    def Map.each_pair(enumerable, *args, &block)
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

    def depth_first_each(*args, &block)
      Map.depth_first_each(enumerable=self, *args, &block)
    end

    def as_array
      array = []
      each_pair do |key, val|
        array[key.to_i] = val if(key.is_a?(Numeric) or key.to_s =~ %r/^\d+$/)
      end
      array
    end

    def new(*args, &block)
      self.class.new(*args, &block)
    end

    def method_missing(m, *a, &b)
      key, setter = m.to_s.split(%r/(=)/)
      hash = self
      if setter
        val = a.size <= 1 ? a.shift : a
        hash[key] = val
        val
      else
        super unless has_key?(key)
        hash[key]
      end
    end
  end
end
