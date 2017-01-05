describe User, type: :model do
  it 'defaults to the right status' do
    user = create(:user)
    expect(user.status).to eq 'pending_language'
  end
end
