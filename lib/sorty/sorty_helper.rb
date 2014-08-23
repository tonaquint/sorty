module Sorty
  module SortyHelper
    def sorty(column, title = nil, options={default: false, anchor: nil})
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      default = options.try(:[], :default)
      anchor = options.try(:[], :anchor)
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
            sorty_anchor: anchor,
          },
        },
      }
      link_to title, params.merge(preserved_params).merge(anchor: anchor), {class: css_class}
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    helper Sorty::SortyHelper
  end
end
