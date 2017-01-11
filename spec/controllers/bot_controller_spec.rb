describe BotController, type: :controller do
  before do
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:reply_message)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:validate_signature).and_return 'all good'
    @company = create(:company, size: 4)
  end

  describe 'new follow event' do
    include_context 'mock follow'

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
      before { @mock_value = 'yada yada' }
      include_context 'mock text'

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
      before { @mock_value = 'language=th' }
      include_context 'mock postback'

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
      before do
        @question = create(:question_with_options, metric: create(:metric),
                           timing: :welcome)
      end
      context 'token matches' do
        before { @mock_value = @token.name }
        include_context 'mock text'

        it 'updates the user status and token itself' do
          expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
            .with('T1234', [
              hash_including(text: /Welcome to team Gotham Industries!/),
              hash_including(text: /Great job completing/),
              hash_including(template: hash_including(
                title: 'General',
                text: 'Do you like coffee?'
              ))
            ])
          # TODO: test the feedback_request is created only once for the company
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
          expect(@token.reload.user).to eq @user
        end
      end

      context 'the token is in the wrong case' do
        before { @mock_value = @token.name.downcase }
        include_context 'mock text'

        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
        end
      end

      context 'the token is a part of a sentence' do
        before { @mock_value = "my password is #{@token.name} :)" }
        include_context 'mock text'

        it 'updates the user status' do
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
        end
      end
    end

    context 'company is not found' do
      before { @mock_value = "no idea :(" }
      include_context 'mock text'

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
    end

    context 'switching the language' do
      before do
        @mock_value = 'language=en'
        @user.update(language: 'th')
      end
      include_context 'mock postback'

      it 'switches the language, but does not request password' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', hash_including(text: /is now English/))
        post :callback
        expect(@user.reload.language).to eq 'en'
        expect(I18n.locale).to eq :en
      end
    end

    context 'receiving postback feedback' do
      before { @mock_value = "feedback_request_id=1&value=100" }
      include_context 'mock postback'

      it 'sends out a thank you' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234',
            hash_including(text: /Thank you!/)
          )
        post :callback
      end
    end

    xcontext 'receiving text input' do
      before { @mock_value = "tokEN" }
      include_context 'mock text'

      it 'saves it with a tag' do
        # TODO: check the right payload content
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with('T1234', hash_including(type: /template/))
        post :callback
      end
    end
  end
end
