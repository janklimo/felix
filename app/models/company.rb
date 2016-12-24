class Company < ActiveRecord::Base
  belongs_to :admin

  validates :name, presence: true
  validates :password, presence: true, uniqueness: true
  validates :latitude, :longitude, numericality: true

  before_validation :normalize_password

  private

  def normalize_password
    self.password = self.password.upcase if self.password
  end
end
