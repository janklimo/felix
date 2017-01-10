describe Question, type: :model do
  it 'validates for length' do
    question = build(:question)
    question.en = nil
    question.th = nil
    expect(question).not_to be_valid

    question.en = 'This is a question in English. It is pretty ' \
      'good but really long.'
    question.th = 'This is the Thai version and it is ok.'
    expect(question).not_to be_valid

    question.th = 'This is a question in Thai. It is pretty ' \
      'good but really long.'
    question.en = 'This is the English version and it is ok.'
    expect(question).not_to be_valid

    question.en = 'Money'
    question.th = 'Money in Thai'
    expect(question).to be_valid
  end

  it 'destroys dependent options' do
    question = create(:question)
    question.options << create(:option)
    question.options << create(:option)
    expect(Option.count).to eq 2
    question.destroy!
    expect(Option.count).to eq 0
  end
end
