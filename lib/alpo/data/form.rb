module Alpo
  class Data
    class Form
      include Tagz.globally

      attr 'data'

      def initialize(data)
        @data = data
      end

      def input(*args)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        type = options.delete(:type) || :text
        name = options.delete(:name) || name_for(keys)
        value = options.delete(:value) || data.get(keys)
        id = options.delete(:id) || id_for(keys)
        klass = options.delete(:class) || class_for(keys)

        input_(options.merge(:type => type, :name => name, :value => value, :class => klass, :id => id)){}
      end

      def button(*args)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        type = options.delete(:type) || :button
        name = options.delete(:name) || name_for(keys)
        value = options.delete(:value) || data.get(keys)
        id = options.delete(:id) || id_for(keys)
        klass = options.delete(:class) || class_for(keys)

        button_(options.merge(:type => type, :name => name, :value => value, :class => klass, :id => id)){}
      end

      def textarea(*args)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        value = options.delete(:value) || data.get(keys)
        name = options.delete(:name) || name_for(keys)
        id = options.delete(:id) || id_for(keys)
        klass = options.delete(:class) || class_for(keys)

        textarea_(options.merge(:name => name, :class => klass, :id => id)){ value }
      end

# TODO
      def select(*args)
      end

      def id_for(keys)
        if((prefix = data._prefix))
          Slug.for("#{ prefix }_#{ keys.join('-') }")
        else
          Slug.for(*keys)
        end
      end

      def class_for(keys)
        klass =
          if((name = data._name))
            "#{ name }"
          end
        klass = [klass, 'errors'].compact.join(' ') if data.errors.on?(keys)
        klass
      end

      def name_for(keys)
        prefix = data._prefix
        "#{ prefix }(#{ keys.flatten.join(',') })"
      end
    end
  end
end
