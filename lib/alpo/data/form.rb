module Alpo
  class Data
    class Form
      include Tagz.globally

      attr 'data'

      def initialize(data)
        @data = data
      end

      def errors
        data.errors
      end

      def label(*args, &block)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        name = options.delete(:name) || keys.last
        id = options.delete(:id) || id_for(keys)
        klass = class_for(keys, options.delete(:class))

        content =
          if block.nil? and !options.has_key?(:content) 
            name.to_s.humanize
          else
            block ? block.call() : options.delete(:content)
          end

        label_(options_for(options, :name => name, :class => klass, :id => id)){ content }
      end

      def input(*args, &block)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        type = options.delete(:type) || :text
        name = options.delete(:name) || name_for(keys)
        id = options.delete(:id) || id_for(keys)
        klass = class_for(keys, options.delete(:class))

        value =
          if block.nil? and !options.has_key?(:value) 
            value_for(data, keys)
          else
            block ? block.call(data.get(keys)) : options.delete(:value)
          end

        input_(options_for(options, :type => type, :name => name, :value => value, :class => klass, :id => id)){}
      end

      def submit(*args, &block)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        options[:type] = :submit
        options[:value] = block ? block.call : :Submit
        args.push(options)
        input(*args)
      end

      def button(*args)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        type = options.delete(:type) || :button
        name = options.delete(:name) || name_for(keys)
        id = options.delete(:id) || id_for(keys)
        klass = class_for(keys, options.delete(:class))

        value =
          if block.nil? and !options.has_key?(:value) 
            value_for(data, keys)
          else
            block ? block.call(data.get(keys)) : options.delete(:value)
          end

        button_(options_for(options, :type => type, :name => name, :value => value, :class => klass, :id => id)){}
      end

      def reset(*args)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        options[:type] = :reset
        args.push(options)
        button(*args)
      end

      def textarea(*args, &block)
        options = Alpo.hash_for(args.last.is_a?(Hash) ? args.pop : {})
        keys = args.flatten

        name = options.delete(:name) || name_for(keys)
        id = options.delete(:id) || id_for(keys)
        klass = class_for(keys, options.delete(:class))

        value =
          if block.nil? and !options.has_key?(:value) 
            value_for(data, keys)
          else
            block ? block.call(data.get(keys)) : options.delete(:value)
          end

        tagz {
          textarea_(options_for(options, :name => name, :class => klass, :id => id))
          tagz << value
          _textarea
        }
      end

# TODO - this needs some thinking
#
      def select(*args)
      end

      def id_for(keys)
        id = [data.key, keys.join('-')].compact.join('_')
        Slug.for(id)
      end

      def class_for(keys, klass = nil)
        klass = [klass, 'alpo', 'errors'].compact.join(' ') if data.errors.on?(keys)
        klass
      end

      def value_for(data, keys)
        return nil unless data.has?(keys)
        value = Tagz.escapeHTML(data.get(keys))
      end

      def options_for(*hashes)
        hash = HashWithIndifferentAccess.new
        hashes.flatten.each do |h|
          h.each do |k,v|
            hash[k] = v unless v.nil?
          end
        end
        hash
      end

      def name_for(keys)
        "#{ data.key }(#{ keys.flatten.join(',') })"
      end
    end
  end
end
