class Metric < ActiveRecord::Base
  validates :name, presence: true
end
