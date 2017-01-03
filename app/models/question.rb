class Question < ActiveRecord::Base
  include RankedModel
  ranks :row_order

  belongs_to :metric
end
