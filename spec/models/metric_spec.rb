describe Metric, type: :model do
  it 'needs a name' do
    metric = build(:metric)
    metric.name = nil
    expect(metric).not_to be_valid
    metric.name[:en] = 'Money'
    expect(metric).to be_valid
  end
end
