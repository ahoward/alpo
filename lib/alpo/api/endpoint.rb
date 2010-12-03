module Alpo
  class Api
    module Endpoint
      attr_accessor :path
      attr_accessor :description
      attr_accessor :signature

      def Endpoint.extend_object(object)
        super
      end
    end
  end
end
