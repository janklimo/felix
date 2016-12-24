describe AdminController, type: :controller do
  context 'not logged in' do
    it 'redirects to safety' do
      get :home
      expect(flash[:alert]).to match 'need to sign in'
      expect(response).to redirect_to new_admin_session_path
    end
  end
end
