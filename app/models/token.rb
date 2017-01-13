class Token < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  validates :name, presence: true, uniqueness: true

  before_validation :set_token_name, on: :create

  scope :available, -> { where(user_id: nil) }

  private

  def set_token_name
    self.name = random_token
    set_token_name if Token.exists?(name: self.name)
  end

  # outputs a string of 5 to 6 characters long
  def random_token
    rand(36**6).to_s(36).upcase
  end
end
