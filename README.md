# Sorty

Sorty is a simple gem for ordering records returned from your Rails application as an ActiveRecord::Relation.

Using a simple syntax, it creates a basic "whitelist" of attributes that you permit your end users to sort your models by.

## Installation

```ruby
gem 'sorty', git: 'git@github.com:mark-d-holmberg/sorty.git'
```

## The Model

The simple invocation's follow:

```ruby
# app/models/lead.rb
class Lead < ActiveRecord::Base
  sorty on: [:last_name, :first_name, :business_name],
    references: {assignable: "full_name"}
end
```

The `on` parameter indicates to Sorty that it is an actual database backed column. The `references` hash indicates an association
you plan to sort by, in this case, a Lead is assigned to a User (assignable), and we're going to order by the `full_name` attribute
on the `User` table.

Sorty will use reflection to try to determine the proper tables and what not.

## The Controller

In the controller, you can invoke something like the following (here, I am using CanCan)

```ruby
# app/controllers/leads_controller.rb
  class LeadsController < ApplicationController
    def index
      if params[:search].try(:[], :sorty).present?
        @leads = @leads.sorty_order(sort_column, sort_direction)
      else
        @leads = @leads.ordered
      end
    end
  end
```

The `sort_column` and `sort_direction` methods are provided by Sorty behind the scenes.

# The View

Sorty provides a helper for easily creating a form to submit the Sorty parameters. It is customized to persist other search parameters. YMMV.

In your index template (or wherever you choose to have sorty-ing) you can use the following pattern:

```haml
%table.table.table-striped.table-hover.table-condensed#leads
  %thead
    %th= sorty "business_name", Lead.human_attribute_name(:business_name), true
    %th= sorty "last_name", Lead.human_attribute_name(:last_name)
    %th= sorty "first_name", Lead.human_attribute_name(:first_name)
    %th= sorty "assignable", Lead.human_attribute_name(:assignable)
  %tbody
    - @leads.each do |lead|
      %tr
        %td= lead.business_name
        %td= lead.last_name
        %td= lead.first_name
        %td= lead.assignable.full_name
```

The `sorty` helper takes the following parameters: `column`, `title`, and `default`. If `default` is set, it will sort records the opposite direction.
