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
        payload = [
          text(I18n.t('hello')),
          text(I18n.t('request_password'))
        ]
      when Line::Bot::Event::Message
        user = User.find_by(external_id: user_id)

        case event.type
        when Line::Bot::Event::MessageType::Text
          text = event['message']['text'].upcase

          if user && user.pending_password?
            if keyword = Company.pluck(:password).find { |str| text.include? str }
              found_company = Company.find_by(password: keyword)
              user.update(company: found_company, status: :pending_location)
              payload = [
                text(I18n.t('company_found', name: found_company.name)),
                text(I18n.t('request_location', name: found_company.name)),
                found_company.map_message
              ]
            else
              payload = text(I18n.t('company_not_found'))
            end
          end
        when Line::Bot::Event::MessageType::Location
          latitude = event['message']['latitude']
          longitude = event['message']['longitude']
          if user && user.pending_location?
            company = user.company
            dist = Geocoder::Calculations.distance_between(
              company.coordinates, [latitude, longitude], units: :km
            )
            # approve the user if he's reasonably close - deviations happen
            if dist < 0.2
              user.update(status: :verified)
              payload = [
                text(I18n.t('location_found', name: company.name)),
                text(I18n.t('what_happens_next'))
              ]
            else
              payload = text(I18n.t('location_not_found'))
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

  def text(content)
    {
      type: 'text',
      text: content
    }
  end
end
