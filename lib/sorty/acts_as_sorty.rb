module Sorty
  module ActsAsSorty
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def sorty(options={})
        include Sorty::SortyModel
        setup_sorty(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Sorty::ActsAsSorty
