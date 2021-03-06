require "administrate/base_dashboard"

class QuestionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    metric: Field::BelongsTo,
    options: Field::HasMany,
    id: Field::Number,
    en: Field::String,
    th: Field::String,
    timing: Enum.with_options(searchable: false),
    row_order: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :metric,
    :en,
    :th,
    :options,
    :timing
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :metric,
    :options,
    :id,
    :en,
    :th,
    :timing,
    :row_order,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :metric,
    :options,
    :en,
    :th,
    :timing,
    :row_order,
  ].freeze

  def display_resource(question)
    question.title[:en]
  end
end
