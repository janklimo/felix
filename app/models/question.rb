class Question < ActiveRecord::Base
  serialize :title, HashSerializer
  store_accessor :title, :en, :th

  include RankedModel
  ranks :row_order

  belongs_to :metric
  has_many :options

  validates :en, :th, presence: true
  validates :en, :th, length: { maximum: 60 }
end
