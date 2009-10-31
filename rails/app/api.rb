load File.join(RAILS_ROOT, '../lib/alpo.rb')

class Api
  
  attr_accessor :real_user
  attr_accessor :effective_user


  def initialize(*args)
    options = args.extract_options.to_options!

    @real_user = User.for options[:real_user]
    @effective_user = User.for options[:effective_user]
  end

  def login(options = {})
    options = options.to_options!

    data = Alpo.data.new

    return data if options.empty?
  end

end
