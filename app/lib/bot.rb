class Bot < Line::Bot::Client
  def initialize
    super(
      channel_secret: ENV["LINE_CHANNEL_SECRET"],
      channel_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end

  def reply(token, payload, user_id)
    return unless payload
    payload = [payload] if payload.is_a? Hash
    payload.each_with_index do |message, i|
      if i == 0
        res = reply_message(token, message)
      else
        res = push_message(user_id, message)
      end
      p res.body if res
      # act more natural by outputting the messages with a bit of a delay
      # don't sleep after the last message
      sleep 4 unless payload.size == (i + 1)
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
