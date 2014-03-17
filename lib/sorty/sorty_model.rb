module Sorty
  module SortyModel

    module ClassMethods
      def setup_sorty(options={})
        self.my_sorty_storage = SortyStorage.new(options.try(:[], :on), options.try(:[], :references))
      end

      def valid_directions
        ["asc", "desc"]
      end

      def sorty_order(column, direction)
        result = all

        # Explicitly return IMMEDIATELY if this thing is nil
        return result if column.nil?

        # First, check again (at the model level) to ensure that we allow the garbage coming in
        if (self.column_names.include?(column) && self.sorty_fields.include?(column.to_sym)) || (self.reflections.keys.include?(column.to_sym) && self.sorty_references.include?(column.to_sym))
          # We know it's either a native field or a reflection (association)
          if self.sorty_references.include?(column.to_sym) && self.valid_directions.include?(direction)
            # assocations that get referenced
            my_klass = self.reflect_on_association(column.to_sym).klass
            result = result.includes(column.to_sym).order("#{my_klass.table_name}.#{self.sorty_references[column.to_sym]} #{direction}").references(column.to_sym)
          else
            if self.sorty_fields.include?(column.to_sym) && self.valid_directions.include?(direction)
              # Actual database columns
              result = result.order(column + " " + direction)
            end
          end
        end

        result
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :cattr_accessor, :my_sorty_storage
      delegate :sorty_fields, to: :my_sorty_storage
      delegate :sorty_references, to: :my_sorty_storage
    end

  end

  class SortyStorage
    attr_accessor :sorty_fields, :sorty_references

    def initialize(fields, references)
      fields ||= []
      references ||= {}
      @sorty_fields = fields
      @sorty_references = references
    end
  end
end
