module Alpo
  class Api
    attr_accessor :mode
    attr_accessor :namespace

    def Api.new(*args, &block)
      api = allocate
      api.instance_eval do
        @mode = :read
        @catching = false
        initialize(*args, &block)
      end
      api
    end

    def mode= mode
      @mode = mode.to_s.strip.downcase.to_sym
    end

    def read(&block)
      mode = self.mode
      self.mode = :read
      if block
        begin; block.call(self); ensure; self.mode = mode; end
      else
        self
      end
    end
    alias_method 'get', 'read'

    def read?(&block)
      condition = @mode == :read
      if block.nil?
        condition
      else
        if condition
          result = block.call
          throw(:result, result) if catching?
          result
        end
      end
    end
    alias_method 'get?', 'read?'

    def write(&block)
      mode = self.mode
      self.mode = :write
      if block
        begin; block.call(self); ensure; self.mode = mode; end
      else
        self
      end
    end
    alias_method 'post', 'write'

    def write?(&block)
      condition = @mode == :write
      if block.nil?
        condition
      else
        if condition
          result = block.call
          throw(:result, result) if catching?
          result
        end
      end
    end
    alias_method 'post?', 'write?'

    def catching(label = :result, &block)
      catching = @catching
      @catching = true
      catch(label, &block)
    ensure
      @catching = catching
    end

    def catching?
      @catching
    end

    class Namespace < Module
      def method_added(method)
        private(method)
      end

      def endpoint(name, &block)
        name = name.to_s
        impl = name + '_impl'
        define_method(name) do |*args|
          args.push(HashWithIndifferentAccess.new) if args.empty?
          catching{ send(impl, *args) }
        end
        define_method(impl, &block)
        public(name)
      end
      alias_method('Endpoint', 'endpoint')

      def name
        @name
      end

      def inspect
        "Namespace(#{ name })"
      end

      def Namespace.new(name, &block)
        namespace = super(&block)
      ensure
        namespace.instance_eval{ @name = name }
      end
   end

    class << Api
      def Namespace(name, &block)
        name = name.to_s.downcase.strip.to_sym 

        namespace = namespaces[name]

        if block
          if namespace
            namespace.module_eval(&block)
          else
            namespace = namespaces[name] = Namespace.new(name, &block)
            define_method(name) do
              namespaced = self.dup
              namespaced.extend(namespace)
              namespaced.namespace = namespace
              namespaced
            end
          end
        end

        namespace
      end
      alias_method 'namespace', 'Namespace'

      def namespaces
        @namespaces ||= Hash.new
      end

      def endpoint(name, &block)
        define_method(name, &block)
      #ensure
        #(endpoints << name).uniq!
      end

      def endpoints
        @endpoints ||= []
      end
    end
  end

  def api(&block)
    block ? Class.new(Api, &block) : Api
  end
end
