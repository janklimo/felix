class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_request

  enum tag: [:postback, :idea, :problem]
end
