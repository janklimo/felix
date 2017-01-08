describe Option, type: :model do
  it 'validates for length' do
    option = build(:option)
    option.en = nil
    option.th = nil
    expect(option).not_to be_valid

    option.en = 'This option is too long.'
    option.th = 'This one is ok.'
    expect(option).not_to be_valid

    option.th = 'This option is too long.'
    option.en = 'This one is ok.'
    expect(option).not_to be_valid

    option.en = 'Awesome'
    option.th = 'Thai version'
    expect(option).to be_valid
  end
end
