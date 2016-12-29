describe 'Company', type: :feature do
  before do
    @admin = create(:admin)
    login_as(@admin, :scope => :admin)
  end

  describe "creating the company" do
    it 'works' do
      visit admin_home_path
      expect(page).to have_content 'your home, welcome'
      click_link 'Create'
      expect(page).to have_content 'New Company'
      fill_in 'company[name]', with: 'Tripler'
      fill_in 'company[size]', with: 42
      click_button 'Create Company'
      expect(page).to have_content 'has been created'
    end
  end

  describe 'tokens' do
    before do
      @company = create(:company, admin: @admin)
    end
    it 'are listed' do
      visit admin_home_path
      expect(page).to have_content 'these available tokens'
      expect(page).to have_content @company.tokens.last.name
    end
  end
end
