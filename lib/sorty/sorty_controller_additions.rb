module Sorty
  module SortyControllerAdditions

    module ClassMethods
      def sorty_model(model_name)
        self.class_variable_set(:@@sorty_model_name, model_name)
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :sort_column, :sort_direction, :sorty_model, :sorty_anchor, :sorty_anchor?
    end

    attr_accessor :sorty_association_klass_name

    private

    def sorty_association_klass(my_klass_name)
      @sorty_association_klass_name = my_klass_name
    end

    def sort_column
      # Find out if they specified the sorty klass name
      if self.sorty_model_name.present?
        my_klass = self.sorty_model_name.classify.constantize
      elsif sorty_association_klass_name.present?
        my_klass = sorty_association_klass_name.classify.constantize
      else
        my_klass = self.controller_name.classify.constantize
      end

      if params[:search].try(:[], :sorty).present?
        if params[:search][:sorty].try(:[], :sort).present?
          # We assume the controller is named the same thing as the class
          if my_klass.sorty_references.include?(params[:search][:sorty][:sort].to_sym)
            params[:search][:sorty][:sort]
          else
            if my_klass.column_names.include?(params[:search][:sorty][:sort]) && my_klass.sorty_fields.include?(params[:search][:sorty][:sort].to_sym)
              # Make sure the database actually has that column and also that we explicitly say that we can sorty by that column
              params[:search][:sorty][:sort]
            else
              # Don't create the sorty link/form because this thing is bogus
              nil
            end
          end
        end
      end
    end

    def sort_direction
      if params[:search].try(:[], :sorty).present?
        if params[:search][:sorty].try(:[], :direction).present?
          %w[asc desc].include?(params[:search][:sorty][:direction]) ? params[:search][:sorty][:direction] : "asc"
        end
      end
    end

    def sorty_anchor
      if params[:search].try(:[], :sorty).present?
        if params[:search][:sorty].try(:[], :sorty_anchor).present?
          (params[:search][:sorty][:sorty_anchor].present?) ? params[:search][:sorty][:sorty_anchor] : nil
        end
      end
    end

    def sorty_anchor?(my_anchor)
      (sorty_anchor && (sorty_anchor == my_anchor))
    end

  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Sorty::SortyControllerAdditions
    self.send :cattr_accessor, :sorty_model_name
  end
end
