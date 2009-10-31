module Alpo
  def normalized_hash(hash = {})
    HashWithIndifferentAccess.new.update(hash)
  end
  alias_method 'hash_for', 'normalized_hash'
end
