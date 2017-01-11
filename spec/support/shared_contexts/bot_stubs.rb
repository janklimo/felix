shared_context 'mock text' do
  before do
    data = JSON.parse(read_fixtures('text.json'))
    hash = { 'message' => { 'text' => @mock_value } }
    attributes = data.deep_merge(hash)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:parse_events_from)
      .and_return [Line::Bot::Event::Message.new(attributes)]
  end
end

shared_context 'mock follow' do
  before do
    data = JSON.parse(read_fixtures('follow.json'))
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:parse_events_from)
      .and_return [Line::Bot::Event::Follow.new(data)]
  end
end

shared_context 'mock postback' do
  before do
    data = JSON.parse(read_fixtures('postback.json'))
    hash = { 'postback' => { 'data' => @mock_value } }
    attributes = data.deep_merge(hash)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:parse_events_from)
      .and_return [Line::Bot::Event::Postback.new(attributes)]
  end
end
