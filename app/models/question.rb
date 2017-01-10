class Question < ActiveRecord::Base
  serialize :title, HashSerializer
  store_accessor :title, :en, :th

  include RankedModel
  ranks :row_order

  enum timing: [ :welcome, :weekly, :cycle ]

  belongs_to :metric
  has_many :options, dependent: :destroy

  validates :en, :th, presence: true
  validates :en, :th, length: { maximum: 60 }
end
