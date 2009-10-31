module Alpo
  module ParameterParser
    def parse_params(name, hash = {})
      data = Alpo::Data.new(name)

      name = data._name
      re = %r/^ #{ Regexp.escape(name) } (?:-([^(]+))? (?: [(] ([^)]+) [)] )? $/x

      hash.each do |key, value|
        next unless(key.is_a?(String) or key.is_a?(Symbol))
        key = key.to_s
        match, id, keys = re.match(key).to_a
        next unless match
        next unless keys
        if id
          id = Data.key_for(id)
          data._id ||= id
        end
        next unless data._id == id
        keys = keys.strip.split(%r/\s*,\s*/).map{|key| key =~ %r/^\d+$/ ? Integer(key) : key}
        data.set(keys => value)
      end

      data
    end

    alias_method 'parse', 'parse_params'
  end

  extend ParameterParser
end
