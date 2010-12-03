begin
  ActiveRecord
  ActiveRecord::Base
rescue NameError
  nil
end

if defined?(ActiveRecord)

  module ActiveRecord
    module ToAlpo
      module ClassMethods
        def to_alpo(*args)

          @to_alpo ||= (
            column_names # + reflect_on_all_associations.map(&:name)
          ).map{|name| name.to_s}

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

        def to_alpo=(*args)
          to_alpo(*args)
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
        #alias_method 'to_map', 'to_alpo' ### HACK
      end
    end

    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.send(:extend, ToAlpo::ClassMethods)
      ActiveRecord::Base.send(:include, ToAlpo::InstanceMethods)
    end
  end

end
