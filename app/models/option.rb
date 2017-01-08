class Option < ActiveRecord::Base
  serialize :title, HashSerializer
  store_accessor :title, :en, :th
  belongs_to :question

  validates :en, :th, presence: true
  validates :en, :th, length: { maximum: 20 }
end
