module Dao
  class Api
    def Api.ClassMethods(&block)
      singleton_class = class << Api; self; end
      singleton_class.module_eval(&block)
    end

    def Api.InstanceMethods(&block)
      module_eval(&block)
    end

    Dao.libdir do
      load 'api/modes.rb'
      load 'api/endpoints.rb'
      load 'api/routes.rb'
      load 'api/dsl.rb'
    end
  end

  def Api.new(*args, &block)
    api = allocate
    api.instance_eval do
      bootstrap(*args, &block)
      before_initialize(*args, &block)
      initialize(*args, &block)
      after_initialize(*args, &block)
    end
    api
  end

  def bootstrap(*args, &block)
    @mode = Mode.for(:read)
    @catching = false
    @stack = Stack.new(params=[], result=[])
  end

  def before_initialize(*args, &block)
    :hook
  end

  def after_initialize(*args, &block)
    :hook
  end


  class Api
    class << Api
      def path(*path)
        self.path = path.first unless path.empty?
        @path ||= '/api'
      end

      def path=(path)
        @path = path.to_s
      end

      def path_for(*paths)
        path = [*paths].flatten.compact.join('/')
        path.squeeze!('/')
        path.sub!(%r|^/|, '')
        path.sub!(%r|/$|, '')
        path.split('/')
      end

      def absolute_path_for(*paths)
        ('/' + path_for(path, *paths).join('/')).squeeze('/')
      end
    end

    Stack = Struct.new(:params, :result)

    def params
      @stack.params.last
    end

    def result
      @stack.result.last
    end

    def catching(label = :result, &block)
      catching = @catching
      @catching = :result
      catch(label, &block)
    ensure
      @catching = catching
    end

    def catching_the_result(&block)
      catching(:result, &block)
    end

    def catching?
      @catching
    end

    def catching_the_result?
      @catching == :result
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
        result = Dao.map_for(args.pop)
      end

      if args.last.is_a?(Hash)
        params = Dao.map_for(args.pop)
      end

      if params.nil? and result
        params = result
        result = nil
      end

      params ||= Dao.hash
      result ||= Dao.hash

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

end
