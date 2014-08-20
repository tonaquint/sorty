module Sorty
  module SortyModel

    module ClassMethods
      delegate :sorty_fields, to: :my_sorty_storage
      delegate :sorty_references, to: :my_sorty_storage

      def setup_sorty(options={})
        self.my_sorty_storage = SortyStorage.new(options.try(:[], :on), options.try(:[], :references), self)
      end

      def valid_directions
        ["asc", "desc"]
      end

      def sorty_order(column, direction)
        result = all

        # Explicitly return IMMEDIATELY if this thing is nil
        return result if column.nil?

        reference = nil
        has_matching_reference = false

        # See if we can find a sorty reference
        if self.sorty_references.present?
          reference = self.sorty_references.find(column.to_sym)
          if reference && reference.sorty_matches?(column.to_sym)
            has_matching_reference = true
          end
        end

        # First, check again (at the model level) to ensure that we allow the garbage coming in
        if (self.column_names.include?(column) && self.sorty_fields.include?(column.to_sym)) || has_matching_reference

          # We know it's either a native field or a reflection (association)
          # if self.sorty_references.include?(column.to_sym) && self.valid_directions.include?(direction)
          if has_matching_reference && self.valid_directions.include?(direction)
            # assocations that get referenced
            my_klass = reference.sorty_parent_klass.reflect_on_association(reference.sorty_association_name.to_sym).klass
            result = result.includes(reference.sorty_association_name.to_sym).order("#{my_klass.table_name}.#{reference.sorty_column_name} #{direction}").references(reference.sorty_association_name.to_sym)

            # my_klass = self.reflect_on_association(column.to_sym).klass
            # result = result.includes(column.to_sym).order("#{my_klass.table_name}.#{self.sorty_references[column.to_sym]} #{direction}").references(column.to_sym)
          else
            if self.sorty_fields.include?(column.to_sym) && self.valid_directions.include?(direction)
              # Actual database columns
              result = result.order([self.table_name, column].join(".") + " " + direction)
            end
          end
        end

        result
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :cattr_accessor, :my_sorty_storage
    end

  end

  class SortyStorage
    attr_accessor :sorty_fields, :sorty_references, :sorty_klass

    def initialize(fields, references, klass)
      @sorty_klass = klass

      fields ||= []
      @sorty_fields = fields

      references ||= []
      @sorty_references = SortyReferenceContainer.new

      references.each do |reference|
        new_reference = SortyReference.new(reference.try(:[], :name), reference.try(:[], :table_name), reference.try(:[], :column_name), klass)
        @sorty_references.add(new_reference)
      end
    end
  end

  class SortyReference
    attr_accessor :sorty_name, :sorty_association_name, :sorty_column_name, :sorty_parent_klass

    def initialize(sorty_name, sorty_association_name, sorty_column_name, sorty_parent_klass)
      @sorty_name             = sorty_name
      @sorty_association_name = sorty_association_name
      @sorty_column_name      = sorty_column_name
      @sorty_parent_klass     = sorty_parent_klass
    end

    def sorty_matches?(column_name)
      if sorty_parent_klass.reflections.keys.include?(sorty_association_name.to_sym) && sorty_parent_klass.sorty_references.include?(column_name.to_sym)
        # We match
        true
      else
        # We don't match
        false
      end
    end
  end

  class SortyReferenceContainer
    attr_accessor :my_sorty_references

    def initialize
      self.my_sorty_references ||= []
    end

    def include?(thing)
      my_sorty_references.map { |k| k.sorty_name.to_s }.include?(thing.to_s)
    end

    def find(reference_name)
      my_sorty_references.select { |k| (k.sorty_name == reference_name.to_s) }.first
    end

    def add(sorty_reference)
      self.my_sorty_references.push(sorty_reference) unless my_sorty_references.include?(sorty_reference)
    end

    def remove(sorty_reference)
      self.my_sorty_references.delete_at(my_sorty_references.index(sorty_reference)) if my_sorty_references.include?(sorty_reference)
    end
  end
end
