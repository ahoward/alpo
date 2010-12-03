class Array
  def to_alpo(*args, &block)
    Alpo.to_alpo(self, *args, &block)
  end
end
