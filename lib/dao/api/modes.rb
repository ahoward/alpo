module Dao
  class Api
    class Mode < ::String
      class << Mode
        def for(mode)
          mode.is_a?(Mode) ? mode : Mode.new(mode.to_s)
        end
      end

      Verbs = %w( options get head post put delete trace connect )

      Verbs.each do |verb|
        const = verb.downcase.capitalize

        unless const_defined?(const)
          mode = Mode.for(verb.downcase)
          const_set(const, mode)
        end
      end

      Read = Get unless defined?(Read)
      Write = Post unless defined?(Write)

      List = Verbs + %w( read write )

      List.each do |method|
        const = method.downcase.capitalize
        define_method(method){ const_get(const) }
      end

      def ==(other)
        super(Mode.for(other))
      end
    end

    ClassMethods {
      def modes(*modes)
        @modes ||= []
        modes.flatten.compact.map{|mode| Api.add_mode(mode)} unless modes.empty?
        @modes
      end

      def add_mode(mode)
        modes.push(mode = Mode.for(mode)).uniq!

        module_eval(<<-__, __FILE__, __LINE__ - 1)

          def #{ mode }(*args, &block)
            if args.empty?
              mode(#{ mode.inspect }, &block)
            else
              mode(#{ mode.inspect }) do
                call(*args, &block)
              end
            end
          end

          def #{ mode }?(&block)
            mode?(#{ mode.inspect }, &block)
          end

        __

        mode
      end
    }

    InstanceMethods {
      def mode=(mode)
        @mode = Mode.for(mode)
      end

      def mode(*args, &block)
        @mode ||= Mode.default

        if args.empty? and block.nil?
          @mode
        else
          if block
            mode = self.mode
            self.mode = args.shift
            begin
              return(instance_eval(&block))
            ensure
              self.mode = mode
            end
          else
            self.mode = args.shift
            return(self)
          end
        end
      end

      def mode?(mode, &block)
        condition = self.mode == mode

        if block.nil?
          condition
        else
          if condition
            result = block.call
            throw(:result, result) if catching_the_result?
            result
          end
        end
      end

      alias_method('get', 'read')
      alias_method('get?', 'read?')

      alias_method('post', 'write')
      alias_method('post?', 'write?')
    }
  end
end
