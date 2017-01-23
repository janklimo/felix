require "administrate/base_dashboard"

class FeedbackDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    feedback_request: Field::BelongsTo,
    id: Field::Number,
    value: Field::Number,
    text: Field::String,
    tag: Enum,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :feedback_request,
    :value,
    :text,
    :tag,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :feedback_request,
    :user,
    :value,
    :text,
    :tag,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :feedback_request,
    :user,
    :value,
    :text,
    :tag,
  ].freeze
end
