# BelongsToAnything

module BelongsToAnything
  class ObjectDoesNotMatch < StandardError;end
  class ActiveRecordMatcherNewRecord < StandardError;end

  class MatcherManager
    def self.match(obj)
      Matchers.singleton_methods.each do |m|
        result = Matchers.method(m).call(obj)
        return result if result
      end

      raise ObjectDoesNotMatch
    end
  end

  #Matcher is simple method that matches (returns unique array of id tokens) or does not match (returns nil) object
  #When 
  module Matchers
    def self.active_record_matcher(obj)
      if defined?(ActiveRecord::Base) && obj.is_a?(ActiveRecord::Base) #obj.is_a? ActiveRecord::Base
        raise ActiveRecordMatcherNewRecord if obj.new_record?
        [obj.class.sti_name, obj.id]
      end
    end

    def self.string_matcher(str)
      [str] if str.is_a?(String)
    end
  end

  module Adapters
    class UniqueStringIdAdapter
      attr_accessor :id_column
      def initialize(base, args = {})
        bta = self
        @id_column = (args[:column] || 'name').to_s

        base.class_eval do |cl|
          cl.extend(ClassMethods)
          cl.send(:cattr_accessor, :bta_adapter)
          cl.bta_adapter = bta
        end
      end

      def unique_string_mixin(obj)
        { id_column => MatcherManager::match(obj).join('-')}
      end

      module ClassMethods
        def record_for(obj)
          find(:first, :conditions => bta_adapter.unique_string_mixin(obj))
        end

        def new_record_for(obj, args = {})
          new(args.merge(bta_adapter.unique_string_mixin(obj)))
        end

        def create_record_for(obj, args = {})
          create(args.merge(bta.unique_string_mixin(obj)))
        end

        def create_record_for(obj, args = {})
          create!(args.merge(bta_adapter.unique_string_mixin(obj)))
        end
      end
    end
  end

  module ActiveRecordExtension
    def belongs_to_anything(args = {})
      Adapters::UniqueStringIdAdapter.new(self, args)
    end
  end
end
