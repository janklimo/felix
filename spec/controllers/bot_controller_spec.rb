describe BotController, type: :controller do
  before do
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:reply_message)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:get_profile).and_return double(body: 'anything')
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:validate_signature).and_return 'all good'
  end

  describe 'new follow event' do
    before do
      allow(JSON).to receive(:parse).and_return mock_follow, mock_profile
    end
    it 'gets the user display name and says hello' do
      expect_any_instance_of(Line::Bot::Client).to receive(:get_profile)
        .with('U1234')
      expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
        .with('T1234', [
          hash_including(text: /Hello Jan! I'm Felix/),
          hash_including(text: /secret keyword/)
        ])
      post :callback
    end
    it 'saves the user with a pending status' do
      post :callback
      expect(User.count).to eq 1
      user = User.first
      expect(user.status).to eq 'pending_password'
      expect(user.external_id).to eq 'U1234'
    end
  end

  describe 'pending password' do
    before do
      @user = create(:user, external_id: 'U1234')
      @company = create(:company, password: 'TOKEN')
    end
    context 'company is found' do
      before do
        allow(JSON).to receive(:parse).and_return mock_text('TOKEN')
      end
      it 'updates the user status' do
        post :callback
        expect(@user.reload.status).to eq 'pending_location'
      end
    end
  end
end
