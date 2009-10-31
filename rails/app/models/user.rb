class User < ActiveRecord::Base
  def User.for(arg)
    arg.is_a?(User) ? arg : User.find(arg)
  end
end
