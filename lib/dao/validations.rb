module Dao
  class Validations < Dao::Map
    class Callback < ::Proc
      attr :options

      def initialize(options = {}, &block)
        @options = Dao.map_for(options || {})
        super(&block)
      end

      def block
        self
      end
    end

    def Validations.for(*args, &block)
      new(*args, &block)
    end

    attr_accessor :result

    def initialize(*args, &block)
      @result = args.shift if args.first.is_a?(Result)
      super
    end

    def data
      raise "no result.data!" unless result
      result.data
    end

    def errors
      data.errors
    end

    def each(&block)
      depth_first_each(&block)
    end

    def size
      size = 0
      depth_first_each{ size += 1 }
      size
    end

    alias_method 'count', 'size'
    alias_method 'length', 'size'

    Cleared = '___CLEARED___'.freeze unless defined?(Cleared)

    def run
      previous_errors = []
      new_errors = []

      errors.each_message do |keys, message|
        previous_errors.push([keys, message])
      end

      errors.clear

      depth_first_each do |keys, callback|
        next unless callback and callback.respond_to?(:to_proc)

        value = data.get(keys)
        valid = !!data.instance_exec(value, &callback)
        message = callback.options[:message] || 'is invalid.'

        unless valid
          new_errors.push([keys, message])
        else
          new_errors.push([keys, Cleared])
        end
      end

      previous_errors.each do |keys, message|
        errors.add(keys, message) unless new_errors.assoc(keys)
      end

      new_errors.each do |keys, value|
        next if value == Cleared
        message = value
        errors.add(keys, message)
      end

      return self
    end

    def run!
      errors.clear!
      run
    end

    def add(*args, &block)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
      block = args.pop if args.last.respond_to?(:call)
      callback = Validations::Callback.new(options, &block)
      args.push(callback)
      set(*args)
    end

    def clone
      clone = Validations.new(data)
      depth_first_each do |keys, callback|
        args = [*keys]
        options = callback.options
        block = callback.block
        args.push(options)
        clone.add(*args, &block)
      end
      clone
    end
  end
end
