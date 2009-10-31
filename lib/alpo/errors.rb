module Alpo
  class Errors < ::Alpo::Data
    def add(*args)
      options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})

      args.flatten!
      message = args.pop
      keys = args
      keys = %w( * ) if keys.empty?

      options[keys] = message if message

      options.each do |keys, message|
        list = get(keys)
        unless get(keys)
          set(keys => [])
          list = get(keys)
        end
        list.push(message)
      end
    end

    alias_method 'add_to_base', 'add'

    def invalid?(*keys)
      !get(keys).nil?
    end

    alias_method 'on', 'get'

    def each(&block)
      Alpo.depth_first_each(enumerable=self, &block)
    end

    def size
      size = 0
      Alpo.depth_first_each(enumerable=self){ size += 1 }
      size
    end

    alias_method 'count', 'size'
    alias_method 'length', 'size'

    def full_messages
      full_messages = []

      depth_first_each do |keys, value|
        index = keys.pop
        key = keys.join('.')
        value = value.to_s
        next if value.strip.empty?
        full_messages.push([key, value])
      end

      full_messages.sort!{|a,b| a.first <=> b.first}
      full_messages
    end

    def each_full
      full_messages.each{|msg| yield msg}
    end
  end
end
