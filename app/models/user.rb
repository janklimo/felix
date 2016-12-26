class User < ActiveRecord::Base
  enum status: [ :pending_password, :pending_location, :verified ]
  belongs_to :company
end
