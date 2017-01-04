describe 'Company', type: :feature do
  describe 'guests' do
    it 'does not allow access to CMS' do
      visit cms_companies_path
      expect(page).to have_content 'has been denied'
    end
  end

  describe 'admins' do
    context 'normal admin' do
      before do
        admin = create(:admin)
        login_as(admin, :scope => :admin)
      end

      it 'does not allow access to CMS' do
        visit cms_companies_path
        expect(page).to have_content 'has been denied'
      end
    end

    context 'super admin' do
      before do
        admin = create(:admin, :superadmin)
        login_as(admin, :scope => :admin)
      end

      it 'does not allow access to CMS' do
        visit cms_companies_path
        expect(page).to have_content 'New company'
      end
    end
  end
end
