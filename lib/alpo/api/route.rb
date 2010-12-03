module Alpo
  class Api
    class Route < ::String
      class << Route
        def like?(route)
          route.to_s =~ %r{/:[^/]+}
        end

        def keys_for(route)
          route = Api.absolute_path_for(route.to_s)
          route.scan(%r{/:[^/]+}).map{|key| key.sub(%r{^/:}, '')}
        end

        def pattern_for(route)
          route = Api.absolute_path_for(route.to_s)
          re = route.gsub(%r{/:[^/]+}, '/([^/]+)')
          /#{ re }/ioux
        end
      end

      attr_accessor :keys
      attr_accessor :pattern
      attr_accessor :params

      def initialize(path)
        replace(path.to_s)
        @keys = Route.keys_for(route)
        @pattern = Route.pattern_for(route)
        @params = Alpo.hash
        freeze
      end

      %w( path name route ).each do |method|
        define_method(method){ self }
      end

      def match(path)
        match = pattern.match(path).to_a
        if match
          @params.clear
          ignored = match.shift
          @keys.each_with_index do |key, index|
            @params[key] = match[index]
          end
          route
        end
      end

      class List < ::Array
        def add(path)
          push(Route.new(path))
        end

        def match(path)
          each do |route|
            match = route.match(path)
            return route if match
          end
          return nil
        end
      end
    end
  end
end
