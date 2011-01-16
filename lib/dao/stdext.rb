class Array
  def to_dao(*args, &block)
    Dao.to_dao(self, *args, &block)
  end
end
