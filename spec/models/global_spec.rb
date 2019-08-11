describe Global, type: :model do

  it 'has a valid factory' do
    expect(build(:global)).to be_valid
  end

  it '::model_types' do
    expect(Global.model_types).to include({ Shop: 'Shop' })
  end

  it 'validates uniqueness of name with model_type' do
    expect(create(:global, name: 'test', model_type: 'Shop')).to be_valid
    expect { create(:global, name: 'test', model_type: 'Shop') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe '::export' do
    let!(:globals) { create_list :global, 3 }

    it 'return all globals' do
      expect(Global.export({})).to match_array(Global.all)
    end
  end
end
