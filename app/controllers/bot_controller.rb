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
          client.text(I18n.t('hello')),
          client.language_selection
        ]
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          text = event['message']['text'].upcase

          if user && user.pending_language?
            payload = client.text(I18n.t('request_language_selection'))
          elsif user && user.pending_password?
            # company found
            if keyword = Token.pluck(:name).find { |str| text.include? str }
              token = Token.find_by(name: keyword)

              # handle available/taken tokens
              if token.user_id
                payload = client.text(I18n.t('token_is_taken'))
              else
                token.update(user: user)
                found_company = token.company
                user.update(company: found_company, status: :verified)

                # create FeedbackRequest and send out the welcome question
                welcome_question = Question.welcome.first
                feedback_request = found_company.feedback_requests
                  .find_or_create_by(question: welcome_question)

                payload = [
                  client.text(I18n.t('company_found', name: found_company.name)),
                  client.text(I18n.t('what_happens_next')),
                  client.template_from_request(feedback_request)
                ]
              end
            # company not found
            else
              payload = client.text(I18n.t('company_not_found'))
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
              client.text(I18n.t('language_selection_confirmed')),
              client.text(I18n.t('request_password'))
            ]
          else
            user.update(language: language)
            payload = client.text(I18n.t('language_selection_confirmed'))
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
            payload = client.text(I18n.t('feedback_request_too_old'))
          else
            feedback.value = data['value']

            # answering the 1st question - say what comes next
            if feedback.new_record? && user.feedbacks.count == 0
              payload = [
                client.text(I18n.t('first_question_answered')),
                client.text(I18n.t('privacy')),
                client.text(I18n.t('text_me_anytime')),
                client.text(I18n.t('how_to_text'))
              ]
            else
              payload = client.text(I18n.t('feedback_received'))
            end

            feedback.save!
          end
        end
      end

      client.reply(event['replyToken'], payload, user_id)
    end

    head :ok
  end

  private

  def client
    @client ||= Bot.new
  end
end
