describe BotController, type: :controller do
  before do
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:reply_message)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:push_message)
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:validate_signature).and_return 'all good'
    allow_any_instance_of(Line::Bot::Client)
      .to receive(:sleep).and_return true
    @company = create(:company, size: 4)
  end

  describe 'new follow event' do
    include_context 'mock follow'

    it 'gets the user display name and says hello' do
      expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
        .with 'T1234', hash_including(text: /Hello amazing! I'm Felix/)
      expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
        .with 'U1234', hash_including(template: hash_including(title: 'Language'))
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
          .with 'T1234', hash_including(text: /Please confirm your language/)
        post :callback
        expect(@user.reload.status).to eq 'pending_language'
      end
    end

    context 'receiving a language postback' do
      before { @mock_value = 'language=th' }
      include_context 'mock postback'

      it 'updates the user language and status, asks for a password' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with 'T1234', hash_including(text: /ภาษาไทยแล้ว/)
        expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
          .with 'U1234', hash_including(text: /TODO/)
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
          token_count = Token.count
          expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
            .with 'T1234', hash_including(text: /Welcome to team Gotham Industries!/)
          expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
            .with 'U1234', hash_including(text: /Great job completing/)
          expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
            .with 'U1234', hash_including(template: hash_including(
              title: 'General',
              text: 'Do you like coffee?'))
          post :callback
          expect(@user.reload.company).to eq @company
          expect(@user.reload.status).to eq 'verified'
          expect(@token.reload.user).to eq @user

          # make sure the token is intact
          expect(@token.reload.name).to eq @mock_value
          expect(Token.count).to eq token_count
        end

        context 'the feedback request already exists' do
          before do
            @fr = create(:feedback_request, question: @question,
                         company: @company)
          end
          it 'does not create a new feedback request' do
            post :callback
            expect(FeedbackRequest.count).to eq 1
            expect(FeedbackRequest.last).to eq @fr
          end
        end

        context 'the token is taken' do
          before { @token.update(user: @user) }
          it 'does not update the user and tells him why' do
            expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
              .with 'T1234', hash_including(text: /Somebody already used/)
            post :callback
            expect(@user.reload.company).to eq nil
            expect(@user.reload.status).to eq 'pending_password'
          end
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

      it 'does not update the user status' do
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with 'T1234', hash_including(text: /doesn't match any of the companies/)
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
          .with 'T1234', hash_including(text: /is now English/)
        post :callback
        expect(@user.reload.language).to eq 'en'
        expect(I18n.locale).to eq :en
      end
    end

    context 'receiving postback feedback' do
      before do
        @fr = create(:feedback_request, question: create(:question),
                     company: @company)
        @mock_value = "feedback_request_id=#{@fr.id}&value=100"
      end
      include_context 'mock postback'

      context 'first answer ever' do
        it 'sends out a thank you and records the feedback' do
          expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
            .with 'T1234', hash_including(text: /your first question/)
          expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
            .with 'U1234', hash_including(text: /100% anonymous/)
          expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
            .with 'U1234', hash_including(text: /text me anytime/)
          expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
            .with 'U1234', hash_including(text: /anything to share now/)
          post :callback
          expect(Feedback.count).to eq 1
          expect(@user.feedbacks.first.feedback_request).to eq @fr
          expect(@user.feedbacks.first.value).to eq 100
        end
      end

      it "can respond to an old question if they haven't yet" do
        @fr.update(created_at: 5.days.ago)
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with 'T1234', hash_including(text: /your first question/)
        expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
          .with 'U1234', hash_including(text: /100% anonymous/)
        expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
          .with 'U1234', hash_including(text: /text me anytime/)
        expect_any_instance_of(Line::Bot::Client).to receive(:push_message)
          .with 'U1234', hash_including(text: /anything to share now/)
        post :callback
        expect(Feedback.count).to eq 1
        expect(@user.feedbacks.first.feedback_request).to eq @fr
        expect(@user.feedbacks.first.value).to eq 100
      end

      context 'feedback already exists' do
        before do
          @feedback = create(:feedback, feedback_request: @fr,
                             user: @user, value: 0)
        end

        context 'there is still time to update' do
          it 'sends out a thank you and updates the feedback' do
            expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
              .with 'T1234', hash_including(text: /a happy cat/)
            post :callback
            expect(Feedback.count).to eq 1
            expect(@user.feedbacks.first.feedback_request).to eq @fr
            expect(@user.feedbacks.first.value).to eq 100
          end
        end

        context "can't edit anymore" do
          it 'does not allow updates' do
            @fr.update(created_at: 4.days.ago,
                       question: create(:question, timing: :cycle))
            expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
              .with 'T1234', hash_including(text: /no longer respond/)
            post :callback
            expect(Feedback.count).to eq 1
            expect(@user.feedbacks.first.feedback_request).to eq @fr
            expect(@user.feedbacks.first.value).to eq 0
          end
        end
      end
    end

    xcontext 'receiving text input' do
      before { @mock_value = "tokEN" }
      include_context 'mock text'

      it 'saves it with a tag' do
        # TODO: check the right payload content
        expect_any_instance_of(Line::Bot::Client).to receive(:reply_message)
          .with 'T1234', hash_including(type: /template/)
        post :callback
      end
    end
  end
end
