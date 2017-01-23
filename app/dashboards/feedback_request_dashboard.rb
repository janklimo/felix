require "administrate/base_dashboard"

class FeedbackRequestDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    company: Field::BelongsTo,
    question: Field::BelongsTo,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :company,
    :question,
    :created_at,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :company,
    :question,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :company,
    :question,
  ].freeze
end
