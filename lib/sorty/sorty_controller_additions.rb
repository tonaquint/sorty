module Sorty
  module SortyControllerAdditions

    module ClassMethods
      def sorty_model(model_name)
        self.class_variable_set(:@@sorty_model_name, model_name)
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :sort_column, :sort_direction, :sorty_model
    end

    private

    def sort_column
      if params[:search].try(:[], :sorty).present?
        if params[:search][:sorty].try(:[], :sort).present?
          if self.sorty_model_name.present?
            # We had to explicitly specify the model name
            if self.sorty_model_name.classify.constantize.sorty_references.include?(params[:search][:sorty][:sort].to_sym)
              params[:search][:sorty][:sort]
            end
          else
            klass = self.controller_name.classify.constantize
            # We assume the controller is named the same thing as the class
            if klass.sorty_references.include?(params[:search][:sorty][:sort].to_sym)
              params[:search][:sorty][:sort]
            else
              if klass.column_names.include?(params[:search][:sorty][:sort]) && klass.sorty_fields.include?(params[:search][:sorty][:sort].to_sym)
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
    end

    def sort_direction
      if params[:search].try(:[], :sorty).present?
        if params[:search][:sorty].try(:[], :direction).present?
          %w[asc desc].include?(params[:search][:sorty][:direction]) ? params[:search][:sorty][:direction] : "asc"
        end
      end
    end

  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Sorty::SortyControllerAdditions
    self.send :cattr_accessor, :sorty_model_name
  end
end
