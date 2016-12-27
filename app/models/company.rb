class Company < ActiveRecord::Base
  belongs_to :admin

  validates :name, presence: true
  validates :password, presence: true, uniqueness: true
  validates :latitude, :longitude, numericality: true

  before_validation :normalize_password

  def map_message
    {
      type: 'image',
      previewImageUrl: URI.encode(
        "https://maps.googleapis.com/maps/api/staticmap?" \
        "zoom=16&size=240x240&maptype=roadmap&" \
        "markers=icon:https://s3.amazonaws.com/felixthebot/marker.png|" \
        "#{latitude},#{longitude}&key=#{ENV['GOOGLE_MAPS_KEY']}"
      ),
      originalContentUrl: URI.encode(
        "https://maps.googleapis.com/maps/api/staticmap?" \
        "zoom=16&size=1024x1024&maptype=roadmap&" \
        "markers=icon:https://s3.amazonaws.com/felixthebot/marker.png|" \
        "#{latitude},#{longitude}&key=#{ENV['GOOGLE_MAPS_KEY']}"
      )
    }
  end

  def coordinates
    [ latitude, longitude ]
  end

  private

  def normalize_password
    self.password = self.password.upcase if self.password
  end
end
