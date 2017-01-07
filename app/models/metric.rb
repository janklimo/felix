class Metric < ActiveRecord::Base
  serialize :name, HashSerializer
  store_accessor :name, :en, :th

  validates :name, presence: true
  has_many :questions
end
