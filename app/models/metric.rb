class Metric < ActiveRecord::Base
  serialize :name, HashSerializer
  store_accessor :name, :en, :th

  validates :en, :th, presence: true
  has_many :questions
end
