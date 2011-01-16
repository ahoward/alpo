module Dao
  class Data < Dao::Map
    class << Data 
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

=begin
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
=end
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
  end
end
