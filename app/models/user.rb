class User < ActiveRecord::Base
  enum status: [ :pending_language, :pending_password, :verified ]
  belongs_to :company
  has_one :token
end
