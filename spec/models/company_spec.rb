describe Company, type: :model do
  describe 'validations' do
    it 'validates the presence of name' do
      company = build(:company, name: nil)
      expect(company).not_to be_valid
    end

    it 'validates the numericality of size, must be positive' do
      company = build(:company, size: nil)
      expect(company).not_to be_valid
      company.size = 'anything'
      expect(company).not_to be_valid
      company.size = -23.45
      expect(company).not_to be_valid
      company.size = 9
      expect(company).to be_valid
      company.size = 9.5
      expect(company).to be_valid
      expect(company.size).to eq 9
    end
  end

  describe 'tokens' do
    it 'generates upper case 6 digit tokens' do
      company = create(:company, size: 5)
      expect(company.tokens.count).to eq 7
      expect(company.tokens.last.name.length).to eq 6
    end
  end
end
