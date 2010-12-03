module Alpo
  class Data < Map
    attr_accessor :path
    attr_accessor :errors
    attr_accessor :validations

    Attrs = %w( path errors validations form status )

    def initialize(*args, &block)
      hash = args.last.is_a?(Hash) ? args.pop : {}
      @path = args.join('-') unless args.empty?

      data = self
      @form = Form.new(data)

      if hash.is_a?(Data)
        @path ||= hash.path.clone
        @errors = hash.errors.clone
        @validations = hash.validations.clone
        @status = hash.status.clone
      else
        @path ||= 'data'
        @errors = Errors.new(data)
        @validations = Validations.new(data)
        @status = Status.ok
      end

      super(hash)
    end

    def to_json(*args, &block)
      map = Map.new
      map['_path'] = path
      map['_status'] = [status.code, status.message]
      map['_errors'] = errors
      map.update(self)
      map.to_json(*args, &block)
    end

    def clone
      data = self
      clone = new(data)
    end

    def dup
      clone
    end

    def ==(other)
      path == other.path &&
      #errors == other.errors &&
      #status == other.status &&
      #validations == other.validations &&
      super
    end

    def status(*args)
      unless args.empty?
        options = Alpo.map_for(args.last.is_a?(Hash) ? args.pop : {})
        @status = Status.for(*args)
        @errors.status(@status, options)
      end
      @status
    end

    def status=(*args)
      status(*args)
    end

    def form(*args, &block)
      return @form if(args.empty? and block.nil?)
      @form.form(*args, &block)
    end

    alias_method('error', 'errors')

    def validates(*args, &block)
      validations.add(*args, &block)
    end

    def validate
      validations.run
      errors.empty?
    end

    def valid?(options = {})
      validate and errors.empty? and status.ok?
    end

    def validate!
      validations.run!
      errors.empty?
    end

    def valid!(options = {})
      validate! and errors.empty? and status.ok?
    end

    def blank?
      depth_first_each do |keys, value|
        is_blank = 
          if value.respond_to?(:blank?)
            value.blank?
          else
            case value
              when 0, 0.0, nil, false, '', [], {}
                true
              when String
                value.strip.empty?
              when Array
                value.join.empty?
              when Numeric
                value.to_i == 0
            end
          end
        return false unless is_blank
      end
      return true
    end

    IdKeys =
      %w( id uuid guid ).map{|key| [key, key.to_sym, "_#{ key }", "_#{ key }".to_sym]}.flatten

    def id
      IdKeys.each{|key| return self[key] if has_key?(key)}
      return nil
    end

    def has_id?
      IdKeys.each{|key| return true if has_key?(key)}
      return false
    end

    def new?
      !has_id?
    end

    def new_record?
      !has_id?
    end

    def model_name
      path.to_s
    end

    def slug
      Slug.for(path)
    end

    def parse(params = {})
      Alpo.parse(path, params)
    end

    def apply(other)
      Data.apply(other => self)
    end
    alias_method 'build', 'apply'
    alias_method '+', 'apply'

    unless Object.new.respond_to?(:instance_exec)
      module InstanceExecHelper; end
      include InstanceExecHelper

      def instance_exec(*args, &block)
        begin
          old_critical, Thread.critical = Thread.critical, true
          n = 0
          n += 1 while respond_to?(mname="__instance_exec_#{ n }__")
          InstanceExecHelper.module_eval{ define_method(mname, &block) }
        ensure
          Thread.critical = old_critical
        end
        begin
          ret = send(mname, *args)
        ensure
          InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
        end
        ret
      end
    end

    Apply = ::Struct.new(:blacklist, :whitelist).new([], [])

    class << Data
      def apply_whitelist
        Apply.whitelist
      end

      def apply_blacklist
        Apply.blacklist
      end

      def apply(*args)
        if args.size == 1 and args.first.is_a?(Hash)
          updates, hash = args.first.to_a.flatten
        else
          updates, hash, *ignored = args
        end

        updates = Alpo.data(hash.path, updates)
        result = Alpo.data(hash.path, hash)

        blacklist = Apply.blacklist
        whitelist = Apply.whitelist

        updates.depth_first_each do |keys, val|
          unless whitelist.empty?
          end

          unless blacklist.empty?
          end

          next if keys.compact.empty?
          next if val.nil?

          result.set(keys => val)
        end

        result
      end

      def build(*args)
        path = args.shift
        result = apply(*args)
        result.path = path
        result
      end
    end
  end
end
