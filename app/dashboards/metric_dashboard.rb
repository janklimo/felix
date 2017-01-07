require "administrate/base_dashboard"

class MetricDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    questions: Field::HasMany,
    id: Field::Number,
    en: Field::String,
    th: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    image_url: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :en,
    :th,
    :questions,
    :created_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :questions,
    :id,
    :en,
    :th,
    :created_at,
    :updated_at,
    :image_url,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :questions,
    :en,
    :th,
    :image_url,
  ].freeze

  def display_resource(metric)
    metric.name[:en]
  end
end
