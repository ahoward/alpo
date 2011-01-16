module Dao
  class Path < ::String
    class << Path
      def for(*args)
        new(absolute_path_for(*args))
      end

      def absolute(*args)
        new(absolute_path_for(*args))
      end

      def absolute_path_for(*args)
        ('/' + parts_for(*args).join('/')).squeeze('/')
      end

      def parts_for(*args)
        path = [*args].flatten.compact.join('/')
        path.squeeze!('/')
        path.sub!(%r|^/|, '')
        path.sub!(%r|/$|, '')
        parts = path.split('/')
      end

      def cast(*args)
        if args.size == 1
          value = args.first
          value.is_a?(self) ? value : self.for(value)
        else
          self.for(*args)
        end
      end
    end

    attr_accessor :result

    def initialize(*args, &block)
      @result = args.shift if args.first.is_a?(Result)
      super(*args, &block)
    ensure
      normalize! unless absolute?
    end

    def normalize!
      replace(Path.absolute_path_for(self))
    end

    def absolute?
      self[0] = '/'
    end
  end
end
