module Sorty
  module SortyHelper
    module ClassMethods
      def foo
        "foo"
      end
    end

    module InstanceMethods
      def bar
        "bar"
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    helper_method :foo
  end
end
