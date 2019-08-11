describe Category, type: :model do
  it_behaves_like 'status validator'

  describe '.indexed' do
    context 'without matching records' do
      let!(:category) { create :category, :with_html_document_noindex }
      subject { Category.indexed }
      it { is_expected.to be_empty }
    end

    context 'with matching records' do
      let!(:category) { create :category, :with_html_document_index }
      subject { Category.indexed }
      it { is_expected.not_to be_empty }
    end
  end

  describe '::order_by_set' do
    let!(:categories) { create_list :category, 2 }
    it 'returns categories ordered by set' do
      expect(Category.order_by_set(categories.map(&:id)).first).to eq(categories.first)
      expect(Category.order_by_set(categories.map(&:id).reverse).first).to eq(categories.last)
    end
  end

  context '.related_shops' do
    let!(:category) { create :category }
    let!(:shops) { create_list :shop, 2, tier_group: 1 }

    it 'returns related shops in order of relations.id' do
      category.related_tier_1_shop_ids = [shops.first.id, shops.last.id]

      expect(category.reload.related_tier_1_shop_ids.first).to eq(shops.first.id)

      Relation.first.update(id: Relation.last.id + 1)

      expect(category.reload.related_tier_1_shop_ids.first).to eq(shops.last.id)
    end
  end

  context '.is_active?' do
    subject { create(:category, status: 'active').is_active? }
    it { is_expected.to eq(true) }
  end

  context '.is_pending?' do
    subject { create(:category, status: 'pending').is_pending? }
    it { is_expected.to eq(true) }
  end

  context '.is_blocked?' do
    subject { create(:category, status: 'blocked').is_blocked? }
    it { is_expected.to eq(true) }
  end

  context '.is_gone?' do
    subject { create(:category, status: 'gone').is_gone? }
    it { is_expected.to eq(true) }
  end

  context '.parent_slug' do
    let(:parent) { create :category, slug: 'parent-slug' }
    subject { create(:category, parent: parent, main_category: false).parent_slug }
    it { is_expected.to eq('parent-slug') }
  end

  context '.parent_name' do
    let(:parent) { create :category, name: 'Parent Name' }
    subject { create(:category, parent: parent, main_category: false).parent_name }
    it { is_expected.to eq('Parent Name') }
  end

  context '.site_id_and_name' do
    let!(:site) { create :site }

    context 'with Site.current' do
      before { Site.current = site }
      subject { create(:category, name: 'Test Name').site_id_and_name }
      it { is_expected.to eq('Test Name') }
    end

    context 'without Site.current' do
      subject { create(:category, name: 'Test Name').site_id_and_name }
      it { is_expected.to eq("#{site.id } - Test Name") }
    end
  end
end
