module Alpo
  def map_for(*args, &block)
    Map.for(*args, &block)
  end
  alias_method(:hash, :map_for)
  alias_method(:map, :map_for)

  def data_for(*args, &block)
    Data.for(*args, &block)
  end
  alias_method(:data, :data_for)

  def apply(*args)
    Data.apply(*args)
  end

  def build(*args)
    Data.build(*args)
  end

  def to_alpo(object, *args, &block)
    case object
      when Array
        object.map{|element| Alpo.to_alpo(element)}

      else
        if object.respond_to?(:to_alpo)
          object.send(:to_alpo, *args, &block)
        else
          object
        end
    end
  end
end
