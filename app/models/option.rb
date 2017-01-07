class Option < ActiveRecord::Base
  serialize :title, HashSerializer
  store_accessor :title, :en, :th
  belongs_to :question
end
