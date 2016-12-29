class Company < ActiveRecord::Base
  belongs_to :admin
  has_many :tokens

  validates :name, presence: true
  validates :size, numericality: { greater_than: 0 }

  after_commit :generate_tokens, on: :create

  private

  def generate_tokens
    # generate extra tokens for future team members + to reinforce anonymity
    (self.size * 1.5).to_i.times do
      self.tokens << Token.create
    end
  end
end
