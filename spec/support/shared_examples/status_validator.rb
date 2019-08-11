RSpec.shared_examples "status validator" do
  let!(:class_sym) { described_class.name.underscore.to_sym }
  let!(:collection) { create class_sym }

  it 'contains STATUSES Hash' do
    expect(described_class.statuses).to be_a(Hash)
  end

  context 'when status' do
    it 'allowed, is valid' do
      expect(build class_sym, status: described_class.statuses.keys.first).to be_valid
    end

    it 'not allowed, is invalid' do
      expect(build class_sym, status: 'wrong').to_not be_valid
    end
  end
end
