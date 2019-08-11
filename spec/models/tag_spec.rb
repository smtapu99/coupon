describe Tag do

  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(build(:tag)).to be_valid
  end

  it 'is invalid without site' do
    expect(build(:tag, site: nil)).to_not be_valid
  end

  it 'is invalid without word' do
    expect(build(:tag, site: nil)).to_not be_valid
  end

  context 'is invalid if duplicate within site' do
    let!(:other_tag) { create :tag, word: 'Test', site: site }
    subject { build(:tag, word: 'Test', site: site) }
    it { is_expected.to_not be_valid }
  end

  context '::allowed_import_params' do
    subject { Tag.allowed_import_params }
    it do
      is_expected.to match_array([
        'Tag ID',
        'Word',
        'Category Slug',
        'Is Blacklisted',
      ])
    end
  end

  describe '::grid_filter' do
    let!(:other_site) { create :site }
    let!(:tags) { create_list :tag, 2, site: site }
    let!(:other_tags) { create_list :tag, 3, site: other_site }

    context 'filters by Site' do
      subject { Tag.grid_filter(site_id: other_site.id) }
      it { is_expected.to match_array(other_tags) }
    end

    it 'filters by word' do
      expect(Tag.grid_filter(word: tags.first.word)).to match_array([tags.first])
    end

    context 'filters by category' do
      let!(:category) { create :category, site: site }
      let!(:other_category) { create :category, site: other_site }

      before do
        tags.each do |tag|
          tag.update(category: category)
        end
      end

      subject { Tag.grid_filter(category: category.id) }
      it { is_expected.to match_array(tags) }
    end
  end

  context '::grid_filter_dropdowns' do
    let!(:categories) { create_list :category, 2 }
    before do
      Site.current = site
      categories.last.update(status: 'blocked')
    end
    subject { Tag::grid_filter_dropdowns }

    it do
      is_expected.to include(category: [
        { '' => 'all' },
        { categories.first.id => categories.first.name }
      ])
    end
  end
end
