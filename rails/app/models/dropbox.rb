class Dropbox < ActiveRecord::Base
  belongs_to :real_user
  belongs_to :effective_user
end
