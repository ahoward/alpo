begin
  MongoMapper
rescue NameError
  nil
end

if defined?(MongoMapper)

  module MongoMapper
    module ToAlpo
      module ClassMethods
        def to_alpo(*args)

          unless defined?(@to_alpo)
            @to_alpo = column_names.map{|name| name.to_s}
          end

          unless args.empty?
            @to_alpo.clear
            args.flatten.compact.each do |arg|
              @to_alpo.push(arg.to_s)
            end
            @to_alpo.uniq!
            @to_alpo.map!{|name| name.to_s}
          end

          @to_alpo
        end
      end

      module InstanceMethods
        def to_alpo(*args)
          hash = Alpo.hash
          model = self.class

          attrs = args.empty? ? model.to_alpo : args

          attrs.each do |attr|
            value = send(attr)

            if value.respond_to?(:to_alpo)
              hash[attr] = value.to_alpo
              next
            end

            if value.is_a?(Array)
              hash[attr] = value.map{|val| val.respond_to?(:to_alpo) ? val.to_alpo : val}
              next
            end

            hash[attr] = value
          end

          if hash.has_key?(:_id) and not hash.has_key?(:id)
            hash[:id] = hash[:_id]
          end

          hash
        end
        alias_method 'to_h', 'to_alpo'
      end
    end

    MongoMapper::Document::ClassMethods.send(:include, ToAlpo::ClassMethods)
    MongoMapper::Document::InstanceMethods.send(:include, ToAlpo::InstanceMethods)
    MongoMapper::EmbeddedDocument::ClassMethods.send(:include, ToAlpo::ClassMethods)
    MongoMapper::EmbeddedDocument::InstanceMethods.send(:include, ToAlpo::InstanceMethods)
  end

end
