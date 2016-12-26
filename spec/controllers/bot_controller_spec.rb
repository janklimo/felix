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
      allow(JSON).to receive(:parse).and_return mock_follow
    end
    it 'gets the user display name and says hello' do
      expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
        .with('T1234', [
          hash_including(text: /Hello amazing! I'm Felix/),
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
      context 'token matches' do
        before do
          allow(JSON).to receive(:parse).and_return mock_text('TOKEN')
        end
        it 'updates the user status' do
          expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
            .with('T1234', [
              hash_including(text: /Welcome to team Gotham Industries!/),
              hash_including(text: /please share your location/),
              hash_including(originalContentUrl: /staticmap/)
            ])
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'pending_location'
        end
      end

      context 'the token is in the wrong case' do
        before do
          allow(JSON).to receive(:parse).and_return mock_text('tokEN')
        end
        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'pending_location'
        end
      end

      context 'the token is a part of a sentence' do
        before do
          allow(JSON).to receive(:parse).and_return mock_text('my password is Token :)')
        end
        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'pending_location'
        end
      end
    end

    context 'company is not found' do
      before do
        allow(JSON).to receive(:parse).and_return mock_text('no idea :(')
      end
      it 'updates the user status' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', [
            hash_including(text: /doesn't match any of the companies/)
          ])
        post :callback
        expect(@user.reload.company).to eq nil
        expect(@user.reload.status).to eq 'pending_password'
      end
    end
  end

  describe 'verified' do
    before do
      @user = create(:user, external_id: 'U1234', status: :verified)
      allow(JSON).to receive(:parse).and_return mock_text('tokEN')
    end
    it 'does not send anything' do
      expect_any_instance_of(Line::Bot::Client).not_to receive(:reply_message)
      post :callback
    end
  end
end
