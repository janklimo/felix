describe BotController, type: :controller do
  before do
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:reply_message)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:get_profile).and_return double(body: 'anything')
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:validate_signature).and_return 'all good'
    @company = create(:company, size: 4)
  end

  describe 'new follow event' do
    before do
      allow(JSON).to receive(:parse).and_return mock_follow
    end
    it 'gets the user display name and says hello' do
      expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
        .with('T1234', [
          hash_including(text: /Hello amazing! I'm Felix/),
          hash_including(template: hash_including(title: 'Language'))
        ])
      post :callback
    end
    it 'saves the user with a pending language status' do
      post :callback
      expect(User.count).to eq 1
      user = User.first
      expect(user.status).to eq 'pending_language'
      expect(user.external_id).to eq 'U1234'
    end
  end

  describe 'pending language' do
    before do
      @user = create(:user, external_id: 'U1234', status: :pending_language)
    end
    context 'receiving text we do not want' do
      before do
        allow(JSON).to receive(:parse).and_return mock_text('yada yada')
      end
      it 'asks for language confirmation' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234',
            hash_including(text: /Please confirm your language/),
          )
        post :callback
        expect(@user.reload.status).to eq 'pending_language'
      end
    end

    context 'receiving a language postback' do
      before do
        allow(JSON).to receive(:parse).and_return mock_postback('language=th')
      end
      it 'updates the user language and status, asks for a password' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', [
            hash_including(text: /ภาษาไทยแล้ว/),
            hash_including(text: /TODO/)
          ])
        post :callback
        expect(@user.reload.status).to eq 'pending_password'
        expect(@user.reload.language).to eq 'th'
        expect(I18n.locale).to eq :th
        # reset locale
        I18n.locale = :en
      end
    end
  end

  describe 'pending secret token' do
    before do
      @user = create(:user, external_id: 'U1234', status: :pending_password)
      @token = Token.last
    end
    context 'company is found' do
      context 'token matches' do
        before do
          allow(JSON).to receive(:parse).and_return mock_text(@token.name)
        end
        it 'updates the user status and token itself' do
          expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
            .with('T1234', [
              hash_including(text: /Welcome to team Gotham Industries!/),
              hash_including(text: /Great job completing/),
            ])
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
          expect(@token.reload.user).to eq @user
        end
      end

      context 'the token is in the wrong case' do
        before do
          allow(JSON).to receive(:parse)
            .and_return mock_text(@token.name.downcase)
        end
        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
        end
      end

      context 'the token is a part of a sentence' do
        before do
          allow(JSON).to receive(:parse)
            .and_return mock_text("my password is #{@token.name} :)")
        end
        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
        end
      end
    end

    context 'company is not found' do
      before do
        allow(JSON).to receive(:parse).and_return mock_text('no idea :(')
      end
      it 'updates the user status' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234',
            hash_including(text: /doesn't match any of the companies/)
          )
        post :callback
        expect(@user.reload.company).to eq nil
        expect(@user.reload.status).to eq 'pending_password'
      end
    end
  end

  describe 'verified' do
    before do
      @user = create(:user, external_id: 'U1234', status: :verified)
      metric = create(:metric, en: "General")
      question = create(:question, metric: metric)
      question.options << create(:option)
    end

    context 'switching the language' do
      before do
        allow(JSON).to receive(:parse).and_return mock_postback('language=en')
        @user.update(language: 'th')
      end
      it 'switches the language, but does not request password' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', hash_including(text: /is now English/))
        post :callback
        expect(@user.reload.language).to eq 'en'
        expect(I18n.locale).to eq :en
      end
    end

    context 'receiving text input' do
      before do
        allow(JSON).to receive(:parse).and_return mock_text('tokEN')
      end
      it 'sends a test template message' do
        # TODO: check the right payload content
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', hash_including(type: /template/))
        post :callback
      end
    end
  end
end
