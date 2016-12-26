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

        hello_message = {
          type: 'text',
          text: "Hello amazing! " \
            "I'm Felix, your team happiness bot 😻 Let's get started!"
        }
        request_password_message = {
          type: 'text',
          text: "First of all, let me find your company 🚀 Please send me " \
            "your team's secret keyword so I can securely identify it."
        }
        payload = [hello_message, request_password_message]
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          user = User.find_by(external_id: user_id)
          text = event['message']['text'].upcase

          if user && user.pending_password?
            if keyword = Company.pluck(:password).find { |str| text.include? str }
              found_company = Company.find_by(password: keyword)
              user.update(company: found_company, status: :pending_location)
              company_found_message = {
                type: 'text',
                text: "Found it 🤗 Welcome to team #{found_company.name}!"
              }
              request_location_message = {
                type: 'text',
                text: "As a final step to get verified, please share your " \
                  "location with me once you are " \
                  "in #{found_company.name}'s office 🎯 Here's the map:"
              }
              payload = [
                company_found_message,
                request_location_message,
                found_company.map_message
              ]
            else
              company_not_found_message = {
                type: 'text',
                text: "That doesn't match any of the companies I know 😞. Please try again!"
              }
              payload = [ company_not_found_message ]
            end
          end
        end
      end
      client.reply_message(event['replyToken'], payload) if payload
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
