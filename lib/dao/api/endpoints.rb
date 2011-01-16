module Dao
  class Api
    module Endpoint
      attr_accessor :path
      attr_accessor :description
      attr_accessor :signature

      def Endpoint.extend_object(object)
        super
      end
    end

    ClassMethods {
      def endpoints
        @endpoints ||= Map.new
      end

      def endpoint(*args, &block)
        args.flatten!
        args.compact!
        options = Dao.options_for!(args)

        path = absolute_path_for(*args)

        if Route.like?(path)
          routes.add(path)
        end

        module_eval{ 
          define_method(path + '/endpoint', &block)
          arity = block.arity

          define_method(path) do |*args|
            params = Params.for(args.shift || {})
            result = Result.for(path, args.shift || {})

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
              catching_the_result{ send(path + '/endpoint', *args) }
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

      def Endpoint(*args, &block)
        raise NotImplementedError, 'Endpoint'
      end

      def annotate(endpoint, attributes = {})
        attributes = Dao.map_for(attributes)
        endpoint.extend(Endpoint) unless endpoint.is_a?(Endpoint)

        path = attributes[:path]
        description = attributes[:description]
        signature = attributes[:signature]

        endpoint.path = path
        endpoint.description = String(description || path)
        endpoint.signature = Dao.map_for(signature || {})

        endpoint
      end

      def endpoint_for(*paths)
        path = Api.absolute_path_for(*paths)
        endpoint = endpoints[path]
        raise(NameError, path) unless endpoint
        endpoint
      end

      alias_method '[]', 'endpoint_for'

      def description
        description = []
        endpoints.each do |path, endpoint|
          m = Map.new
          m['path'] = endpoint.path
          m['description'] = endpoint.description
          m['signature'] = {}.update(endpoint.signature) # HACK
          description.push(m)
        end
        Dao.data_for(path => description)
      end
    }
  end
end
