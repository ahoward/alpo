module Dao
  class Params < Dao::Map
    def parse(*args, &block)
      hash = args.last.is_a?(Hash) ? args.pop : {}
      path = args.empty? ? 'data' : args.shift
      path = path.to_s
      data = Dao::Data.new(path)
      hash = Map.new.update(hash)
      base = hash[path]
      data.update(base) if base

      path = data.path
      re = %r/^ #{ Regexp.escape(path) } (?: [(] ([^)]+) [)] )? $/x
      missing = true

      hash.each do |key, value|
        next unless(key.is_a?(String) or key.is_a?(Symbol))
        key = key.to_s
        match, keys = re.match(key).to_a
        next unless match
        next unless keys
        keys = keys.strip.split(%r/\s*,\s*/).map{|key| key =~ %r/^\d+$/ ? Integer(key) : key}
        data.set(keys => value)
        missing = false
      end

      block.call(data) if(block and missing)

      data
    end
  end

  def Dao.parse(*args, &block)
    Params.parse(*args, &block)
  end
end
