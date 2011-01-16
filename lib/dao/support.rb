module Dao
  def map_for(*args, &block)
    Map.for(*args, &block)
  end
  alias_method(:hash, :map_for)
  alias_method(:map, :map_for)

  def data_for(*args, &block)
    Data.for(*args, &block)
  end
  alias_method(:data, :data_for)

  def options_for!(args)
    Map.options_for!(args)
  end

  def options_for(args)
    Map.options_for(args)
  end

  def apply(*args)
    Data.apply(*args)
  end

  def build(*args)
    Data.build(*args)
  end

  def to_dao(object, *args, &block)
    case object
      when Array
        object.map{|element| Dao.to_dao(element)}

      else
        if object.respond_to?(:to_dao)
          object.send(:to_dao, *args, &block)
        else
          object
        end
    end
  end
end
