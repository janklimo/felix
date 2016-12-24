require 'line/bot'

describe 'Callback', type: :request do
  context 'failed signature validation' do
    before do
      double = double(validate_signature: nil)
      allow(Line::Bot::Client).to receive(:new).and_return double
    end
    it 'returns 400' do
      post '/callback'
      expect(response.status).to eq 400
    end
  end
end
