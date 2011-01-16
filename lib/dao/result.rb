module Dao
  class Result < ::Map
    StateAttrs   = %w( path status data errors )
    VirtualAttrs = %w( form validations )
    Attrs        = StateAttrs + VirtualAttrs

    def initialize(*args, &block)
      StateAttrs.each{|attr| self[attr] = nil}
      
      options = args.pop if args.last.is_a?(Hash)

      self.path = Path.for(args.join('/'))
      self.status = Status.for(self)
      self.data = Data.for(self)
      self.errors = Errors.for(self)
      self.validations = Validations.for(self)
      self.form = Form.for(self)
    end

    StateAttrs.each do |attr|
      type = attr.capitalize

      module_eval(<<-__, __FILE__, __LINE__ - 1)

        def #{ attr }(*value)
          return(self.#{ attr } = value.first) unless value.empty?
          key = #{ attr.to_s.inspect }
          self[key]
        end

        def #{ attr }=val
          key = #{ attr.to_s.inspect }
          self[key] = #{ type }.cast(val)
        end

      __
    end

    VirtualAttrs.each do |attr|
      type = attr.capitalize

      module_eval(<<-__, __FILE__, __LINE__ - 1)

        def #{ attr }(*value)
          return(self.#{ attr } = value.first) unless value.empty?
          @#{ attr }
        end

        def #{ attr }=val
          @#{ attr } = #{ type }.cast(val)
        end

      __
    end

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
  end
end
