class User < ActiveRecord::Base
  enum status: [ :pending, :verified ]
  belongs_to :company
end
