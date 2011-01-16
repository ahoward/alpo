module Dao
  class Map < ::Map
    add_conversion_method!(:to_dao)
  end
end
