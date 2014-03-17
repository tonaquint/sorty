module Sorty
  module SortyHelper
    def sorty(column, title = nil, default = false)
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      if default
        direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
      else
        direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      end
      preserved_params = {
        search: {
          query: params[:search].try(:[], :query),
          filter: params[:search].try(:[], :filter),
          sorty: {
            sort: column,
            direction: direction,
          },
        },
      }
      link_to title, params.merge(preserved_params), {class: css_class}
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    helper Sorty::SortyHelper
  end
end
