module Alpo
  Alpo.libdir do
    load 'api/mode.rb'
    load 'api/endpoint.rb'
    load 'api/route.rb'
    load 'api/dsl.rb'
  end

  class Api
    class << Api
      def new(*args, &block)
        api = allocate
        api.instance_eval do
          before_initialize(*args, &block)
          initialize(*args, &block)
          after_initialize(*args, &block)
        end
        api
      end

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

      def path_for(*paths)
        path = [*paths].flatten.compact.join('/')
        path.squeeze!('/')
        path.sub!(%r|^/|, '')
        path.sub!(%r|/$|, '')
        path.split('/')
      end

      def absolute_path_for(*paths)
        '/' + path_for(path, *paths).join('/')
      end

      def evaluate(&block)
        @dsl ||= DSL.new(api=self)
        @dsl.evaluate(&block)
      end

      def routes
        @routes ||= Route::List.new
      end

      def endpoint(*args, &block)
        args.flatten!
        args.compact!
        options = Alpo.map_for(args.last.is_a?(Hash) ? args.pop : {})

        path = absolute_path_for(*args)

        if Route.like?(path)
          routes.add(path)
        end

        module_eval{ 
          define_method(path + '/endpoint', &block)
          arity = block.arity

          define_method(path) do |*args|
            params = Alpo.map_for(args.shift || {})
            result = Alpo.data_for(path, args.shift || {})

            args =
              case arity
                when 0
                  []
                when 1
                  [params]
                when 2
                  [params, result]
                else
                  [params, result]
              end

            begin
              @stack.params.push(params)
              @stack.result.push(result)
              catching{ send(path + '/endpoint', *args) }
            ensure
              @stack.params.pop
              @stack.result.pop
            end

            result
          end

          public path
        }

        endpoint = instance_method(path)

        annotate(endpoint, options.merge(:path => path))

        endpoints[endpoint.path] = endpoint
        endpoint
      end

      def annotate(endpoint, attributes = {})
        attributes = Alpo.map_for(attributes)
        endpoint.extend(Endpoint) unless endpoint.is_a?(Endpoint)

        path = attributes[:path]
        description = attributes[:description]
        signature = attributes[:signature]

        endpoint.path = path
        endpoint.description = String(description || path)
        endpoint.signature = Alpo.map_for(signature || {})

        endpoint
      end

      alias_method('Endpoint', 'endpoint')

      def endpoints
        @endpoints ||= Map.new
      end

      def endpoint_for(*paths)
        path = Api.absolute_path_for(*paths)
        endpoint = endpoints[path]
        raise(NameError, path) unless endpoint
        endpoint
      end

      alias_method '[]', 'endpoint_for'

      def path(*path)
        self.path = path.first unless path.empty?
        @path ||= 'api'
      end

      def path=(path)
        @path = path.to_s
      end

      def description
        description = []
        endpoints.each do |path, endpoint|
          m = Map.new
          m['path'] = endpoint.path
          m['description'] = endpoint.description
          m['signature'] = {}.update(endpoint.signature) # HACK
          description.push(m)
        end
        Alpo.data_for(path => description)
      end
    end

    Api.modes('read', 'write')

    Stack = Struct.new(:params, :result)

    def before_initialize(*args, &block)
      @mode = Mode.for(:read)
      @catching = false
      @stack = Stack.new(params=[], result=[])
    end

    def after_initialize(*args, &block)
      :hook
    end

    def params
      @stack.params.last
    end

    def result
      @stack.result.last
    end

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
            return instance_eval(&block)
          ensure
            self.mode = mode
          end
        else
          self.mode = args.shift
          return self
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
          throw(:result, result) if catching?
          result
        end
      end
    end

    alias_method 'get', 'read'
    alias_method 'get?', 'read?'

    alias_method 'post', 'write'
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

    def absolute_path_for(*paths)
      Api.absolute_path_for(*paths)
    end

    def endpoints
      unless defined?(@endpoints)
        @endpoints ||= Map.new
        self.class.endpoints.each do |path, endpoint|
          @endpoints[endpoint.path] = endpoint.bind(self)
        end
      end
      @endpoints
    end

    def route_for(*args)
      self.class.routes.match(*args)
    end

    def call(*args)
      params = result = nil
      if args.last.is_a?(Hash)
        result = Alpo.map_for(args.pop)
      end
      if args.last.is_a?(Hash)
        params = Alpo.map_for(args.pop)
      end
      if params.nil? and result
        params = result
        result = nil
      end
      params ||= Alpo.hash
      result ||= Alpo.hash

      path = Api.absolute_path_for(*args)
      endpoint = endpoints[path]

      if endpoint.nil?
        route = route_for(path)
        params.update(route.params)
        path = route.path
        endpoint = endpoints[path]
      end

      raise(NameError, path) unless endpoint

      endpoint.call(params, result)
    end

    alias_method '[]', 'call'

    def description
      self.class.description
    end

    def respond_to?(*args)
      super(*args) || super(absolute_path_for(*args))
    end
  end

  def api(&block)
    if block
      api = Class.new(Api)
      api.evaluate(&block)
      api
    else
      Api
    end
  end
end
