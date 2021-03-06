module Dao
  class Form
    include Tagz.globally

    class << Form 
      def for(*args, &block)
        new(*args, &block)
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
      super
    end

    def data
      raise "no result.data!" unless result
      result.data
    end

    def ==(other)
      data.object_id == other.data.object_id
    end

    def errors
      data.errors
    end

    def form(*args, &block)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
      keys = args.flatten

      action = options.delete(:action) || '#'
      method = options.delete(:method) || 'post'
      id = options.delete(:id) || id_for(keys)
      klass = class_for(keys, options.delete(:class))

      content =
        if block.nil? and !options.has_key?(:content)
          ''
        else
          block ? block.call(form=self) : options.delete(:content)
        end

      form_(options_for(options, :action => action, :method => method, :class => klass, :id => id)){ content }
    end

    def label(*args, &block)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
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
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
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
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
      options[:type] = :submit
      options[:value] = block ? block.call : :Submit
      args.push(options)
      input(*args)
    end

    def button(*args)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
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
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
      options[:type] = :reset
      args.push(options)
      button(*args)
    end

    def textarea(*args, &block)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
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

      textarea_(options_for(options, :name => name, :class => klass, :id => id)){ value }
    end

    def select(*args, &block)
      options = Dao.map_for(args.last.is_a?(Hash) ? args.pop : {})
      keys = args.flatten

      name = options.delete(:name) || name_for(keys)
      from = options.delete(:from) || options.delete(:select) || options.delete(:all) || options.delete(:list) || data.path

      id = options.delete(:id) || id_for(keys)
      klass = class_for(keys, options.delete(:class))

      select_(options_for(options, :name => name, :class => klass, :id => id)){
        pairs = Array(data[from]).flatten
        pairs.each do |pair|
          result = block.call(pair)
          case result
            when Array
              value, content, selected, *ignored = result
            when Hash
              value = result[:value]
              content = result[:content] || value
              selected = result[:selected]
            else
              value = result
              content = result
              selected = false
          end
          opts = {:value => value}
          opts[:selected] = !!selected if selected
          option_(opts){ content }
        end
      }
    end


    def id_for(keys)
      id = [data.path, keys.join('-')].compact.join('_')
      Slug.for(id).sub(/_+$/, '')
    end

    def class_for(keys, klass = nil)
      klass = [klass, 'dao', 'errors'].compact.join(' ') if data.errors.on?(keys)
      klass
    end

    def value_for(data, keys)
      return nil unless data.has?(keys)
      value = Tagz.escapeHTML(data.get(keys))
    end

    def options_for(*hashes)
      map = Map.new
      hashes.flatten.each do |h|
        h.each{|k,v| map[k] = v unless v.nil?}
      end
      map
    end

    def name_for(keys)
      "#{ data.path }(#{ Array(keys).flatten.compact.join(',') })"
    end
  end
end
