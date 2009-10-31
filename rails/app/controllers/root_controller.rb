class RootController < ApplicationController

  def login
    @data = Alpo.parse(:login, params)
  end
end
