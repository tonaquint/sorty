module Sorty
  class SortyRailtie < Rails::Railtie
    initializer 'sorty.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        include SortyHelper
      end
    end
  end
end
