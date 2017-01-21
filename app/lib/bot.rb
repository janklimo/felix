class Bot < Line::Bot::Client
  def initialize
    super(
      channel_secret: ENV["LINE_CHANNEL_SECRET"],
      channel_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end
end
