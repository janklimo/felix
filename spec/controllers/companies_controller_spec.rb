describe CompaniesController, type: :controller do
  before do
    @admin = create(:admin)
  end

  describe 'create' do
    context 'guest' do
      it 'redirects home' do
        post :create, attributes_for(:company)
        expect(flash[:alert]).to match 'need to sign in'
        expect(response).to redirect_to new_admin_session_path
      end
    end

    context 'successful create' do
      before do
        sign_in(@admin, scope: :admin)
      end
      it 'redirects home with a flash message' do
        post :create, company: attributes_for(:company)
        expect(flash[:notice]).to match 'Yay! Your company has been created'
        expect(response).to redirect_to admin_home_path
      end
    end
  end

  describe 'edit' do
    context 'signed in but the company belongs to somebody else' do
      before do
        sign_in(@admin, scope: :admin)
        @company = create(:company, admin: create(:admin))
      end
      it 'redirects home with a flash message' do
        get :edit, id: @company.id
        expect(flash[:alert]).to match 'denied'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'update' do
    context 'guest' do
      before do
        @company = create(:company, admin: create(:admin))
      end
      it 'redirects home with a flash' do
        patch :update, id: @company.id, name: 'New Name'
        expect(flash[:alert]).to match 'need to sign in'
        expect(response).to redirect_to new_admin_session_path
      end
    end

    context 'signed in but the company belongs to somebody else' do
      before do
        sign_in(@admin, scope: :admin)
        @company = create(:company, admin: create(:admin))
      end
      it 'redirects home with a flash message' do
        patch :update, id: @company.id, company: { name: 'New Name' }
        expect(flash[:alert]).to match 'denied'
        expect(response).to redirect_to root_path
      end
    end

    context 'successful update' do
      before do
        sign_in(@admin, scope: :admin)
        @company = create(:company, admin: @admin)
      end
      it 'redirects home with a flash message' do
        patch :update, id: @company.id, company: { name: 'New Name' }
        expect(flash[:notice]).to match 'company has been updated'
        expect(response).to redirect_to admin_home_path
      end
    end
  end
end
