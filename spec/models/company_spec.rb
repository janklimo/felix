describe Company, type: :model do
  describe 'validations' do
    it 'validates the presence of name' do
      company = build(:company, name: nil)
      expect(company).not_to be_valid
    end

    it 'validates the presence of password' do
      company = build(:company, password: nil)
      expect(company).not_to be_valid
    end

    it 'normalizes password' do
      company = create(:company, password: 'lowercase')
      expect(company.password).to eq 'LOWERCASE'
    end

    it 'validates the uniqueness of password' do
      create(:company, password: 'GOTHAM')
      company = build(:company, password: 'gotham')
      expect(company).not_to be_valid
    end

    it 'validates the numericality of latitude' do
      company = build(:company, latitude: nil)
      expect(company).not_to be_valid
      company.latitude = 'anything'
      expect(company).not_to be_valid
      company.latitude = -23.45
      expect(company).to be_valid
    end

    it 'validates the numericality of longitude' do
      company = build(:company, longitude: nil)
      expect(company).not_to be_valid
      company.longitude = 'anything'
      expect(company).not_to be_valid
      company.longitude = -23.45
      expect(company).to be_valid
    end
  end

  describe 'map_message' do
    before do
      @company = create(:company, latitude: 10.1234, longitude: -200.58)
      allow(ENV).to receive(:[]).and_return('token')
    end
    it 'returns the message object' do
      expect(@company.map_message[:type]).to eq 'image'
      expect(@company.map_message[:previewImageUrl]).to include '240x240'
      expect(@company.map_message[:previewImageUrl]).to include '10.1234,-200.58'
      expect(@company.map_message[:previewImageUrl]).to include 'key=token'
      expect(@company.map_message[:originalContentUrl]).to include '1024x1024'
      expect(@company.map_message[:originalContentUrl]).to include '10.1234,-200.58'
      expect(@company.map_message[:originalContentUrl]).to include 'key=token'
    end
  end

  describe 'coordinates' do
    before do
      @company = create(:company, latitude: 11, longitude: -22)
    end
    it 'returns an array of coordinates' do
      expect(@company.coordinates).to eq [11, -22]
    end
  end
end
