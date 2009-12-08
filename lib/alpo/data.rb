module Alpo
  class Data < HashWithIndifferentAccess
    include HashMethods

    attr_accessor :key
    attr_accessor :errors
    attr_accessor :form
    attr_writer :status

    def initialize(*args, &block)
      data = self
      options = HashWithIndifferentAccess.new(args.last.is_a?(Hash) ? args.pop : {})

      @key = args.shift
      @errors = Errors.new(data)
      @form = Form.new(data)
      @status = Status.ok

      super(options)
    end

    def status
      Status.for(@status)
    end

    alias_method 'error', 'errors'
    alias_method 'f', 'form'

    def valid?()
      errors.empty? and status.ok?
    end
  end

  def data(*args, &block)
    args.push(:data) if args.empty? and block.nil?
    data = Alpo::Data.new(*args)
    block.call(data) if block
    data
  end
end
