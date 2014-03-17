require "action_controller"
require "sorty/sorty_helper"
require "sorty/sorty_controller_additions"
require "sorty/sorty_model"

module Sorty

  def sorty(options={})
    include SortyModel
    setup_sorty_model(options)
  end

end
