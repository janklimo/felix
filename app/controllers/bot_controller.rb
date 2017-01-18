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
      user = User.find_by(external_id: user_id)
      if user
        I18n.locale = user.language.to_sym
      end

      case event
      when Line::Bot::Event::Follow
        # save the user record
        User.create(external_id: user_id)
        payload = [
          text(I18n.t('hello')),
          language_selection
        ]
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          text = event['message']['text'].upcase

          if user && user.pending_language?
            payload = text(I18n.t('request_language_selection'))
          elsif user && user.pending_password?
            # company found
            if keyword = Token.pluck(:name).find { |str| text.include? str }
              token = Token.find_by(name: keyword)

              # handle available/taken tokens
              if token.user_id
                payload = text(I18n.t('token_is_taken'))
              else
                token.update(user: user)
                found_company = token.company
                user.update(company: found_company, status: :verified)

                # create FeedbackRequest and send out the welcome question
                welcome_question = Question.welcome.first
                feedback_request = found_company.feedback_requests
                  .find_or_create_by(question: welcome_question)

                payload = [
                  text(I18n.t('company_found', name: found_company.name)),
                  text(I18n.t('what_happens_next')),
                  template_from_request(feedback_request)
                ]
              end
            # company not found
            else
              payload = text(I18n.t('company_not_found'))
            end
          elsif user && user.verified?
            # TODO record textual feedback with tags
          end
        end
      when Line::Bot::Event::Postback
        value = event['postback']['data']

        # let users change the language at any time
        if user && value.include?('language')
          language = value.split('=').last
          I18n.locale = language.to_sym

          if user.pending_language?
            user.update(language: language, status: :pending_password)
            payload = [
              text(I18n.t('language_selection_confirmed')),
              text(I18n.t('request_password'))
            ]
          else
            user.update(language: language)
            payload = text(I18n.t('language_selection_confirmed'))
          end
        end

        # process all the other postback data
        if user && user.verified? && value.include?('feedback_request_id')
          data = Rack::Utils.parse_nested_query(value)
          feedback_request = FeedbackRequest.find(data['feedback_request_id'])
          feedback = user.feedbacks.find_or_initialize_by(
            feedback_request: feedback_request
          )

          # do not permit answers to old questions except the welcome one
          if feedback.persisted? && (Time.now - feedback_request.created_at) > 3.days &&
              !feedback_request.question.welcome?
            payload = text(I18n.t('feedback_request_too_old'))
          else
            feedback.value = data['value']
            feedback.save!
            payload = text(I18n.t('feedback_received'))
          end
        end
      end
      res = client.reply_message(event['replyToken'], payload) if payload
      p res.body if res
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

  def template_from_request(feedback_request)
    question = feedback_request.question
    metric = question.metric
    {
      "type": "template",
      "altText": question.title[I18n.locale],
      "template": {
        "type": "buttons",
        "thumbnailImageUrl": metric.image_url,
        "title": metric.name[I18n.locale],
        "text": question.title[I18n.locale],
        "actions": question.options.order(value: :desc).map do |option|
          {
            "type": "postback",
            "label": option.title[I18n.locale],
            "data": "feedback_request_id=#{feedback_request.id}&" \
              "value=#{option.value}"
          }
        end
      }
    }
  end

  def language_selection
    {
      "type": "template",
      "altText": "Please choose your language.",
      "template": {
        "type": "buttons",
        "thumbnailImageUrl": "https://s3.amazonaws.com/felixthebot/hello.jpg",
        "title": "Language",
        "text": "What language should I speak?",
        "actions": [
          {
            "type": "postback",
            "label": 'English',
            "data": "language=en"
          },
          {
            "type": "postback",
            "label": 'ภาษาไทย',
            "data": "language=th"
          }
        ]
      }
    }
  end
end
