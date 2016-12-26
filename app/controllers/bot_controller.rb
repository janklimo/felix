require 'line/bot'

class BotController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)
    events.each do |event|
      user_id = event['source']['userId']

      case event
      when Line::Bot::Event::Follow
        # save the user record
        User.create(external_id: user_id)

        # get user display name
        res = client.get_profile(user_id)
        profile = JSON.parse(res.body)
        hello_message = {
          type: 'text',
          text: "Hello #{profile['displayName']}! " \
            "I'm Felix, your team happiness bot 😻 Let's get started!"
        }
        request_password_message = {
          type: 'text',
          text: "Let me find your company 🚀 Please send me your team's secret " \
            "keyword so I can securely identify it."
        }
        client.reply_message(event['replyToken'], [
          hello_message,
          request_password_message
        ])
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'image',
            originalContentUrl: "https://maps.googleapis.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&format=jpg"
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end
end
