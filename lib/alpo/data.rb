module Alpo
  class Data < HashWithIndifferentAccess
    def Data.for(object)
      case @object
        when String, Symbol
          name = @object.to_s
          @object = nil
        else
          type = @object.class.name
          name = type.respond_to?(:underscore) ? type.underscore : Slug.for(type)
          id ||= @object.id
      end
    end

    def initialize(*args)
      options = HashWithIndifferentAccess.new(args.last.is_a?(Hash) ? args.pop : {})

      name = args.shift || :data
      id = args.shift

      name = name.to_s if name

      if id.nil? and name and name['-']
        name, id, *ignored = name.split('-')
      end

      super(options)

      self._name = name if name
      self._id = id if id
    end

    def _name
      self['_name']
    end
    alias_method 'data_name', '_name'
    def _name=(name)
      self['_name'] = name.to_s
    end
    alias_method 'data_name=', '_name='

    def _id
      self['_id']
    end
    alias_method 'data_id', '_id'
    def _id=(id)
      self['_id'] = key_for(id)
    end
    alias_method 'data_id=', '_id='

    def _prefix
      name, id = _name, _id
      return nil if(name.nil? and id.nil?)
      [name, id].compact.join('-')
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

    def set(*args)
      if args.size == 1 and args.first.is_a?(Hash)
        options = args.pop
        keys, value = options.to_a.first
      else
        value = args.pop
        keys = args
      end
      keys = Array(keys).flatten

      collection = self
      return collection[keys.first] = value if keys.size <= 1

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
      return value
    end

    def Data.key_for(key)
      return key if Numeric===key
      key.to_s =~ %r/^\d+$/ ? Integer(key) : key
    end
    def key_for(key)
      Data.key_for(key)
    end

    def method_missing(m, *a, &b)
      key, setter = m.to_s.split(%r/(=)/)
      if setter
        val = a.size<=1 ? a.shift : a
        update(key => val)
      else
        super unless has_key?(key)
        fetch(key)
      end
    end

    def depth_first_each(*args, &block)
      Alpo.depth_first_each(enumerable=self, *args, &block)
    end

    def =~(other)
      dup = self.dup
      dup.delete('_name') unless other.has_key?('_name')
      dup.delete('_id') unless other.has_key?('_id')
      dup == with_indifferent_access(other)
    end

    def form
      @form ||= Form.new(self)
    end

    def errors
      @errors ||= Errors.new(self)
    end

    alias_method 'error', 'errors'

    def new(*args, &block)
      self.class.new(*args, &block)
    end
  end

  def data(*args, &block)
    Alpo::Data.new(*args, &block)
  end
end
