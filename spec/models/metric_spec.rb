describe Metric, type: :model do
  it 'needs a name' do
    metric = build(:metric)
    metric.en = nil
    metric.th = nil
    expect(metric).not_to be_valid

    metric.en = nil
    metric.th = 'Some Thai option'
    expect(metric).not_to be_valid

    metric.en = 'Awesome'
    metric.th = 'Thai version'
    expect(metric).to be_valid
  end
end
