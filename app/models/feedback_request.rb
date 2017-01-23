class FeedbackRequest < ActiveRecord::Base
  belongs_to :company
  belongs_to :question
  has_many :feedbacks, dependent: :destroy
end
