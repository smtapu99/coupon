describe Banner, type: :model do

  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:banner)).to be_valid
  end

  it 'fails if end_date is smaller then start_date' do
    expect{FactoryGirl.create(:banner, start_date: '2018-01-02', end_date: '2018-01-01')}.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'serializes value attribute as hash' do
    banner = FactoryGirl.create(:banner, value: { test: 'abc' })
    expect(banner.value[:test]).to eq 'abc'
  end

  context '::by_type_shop_and_category' do
    it 'returns nil if no banner exists' do
      expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 1, category_id: 1)).to eq nil
    end

    context 'when querying for' do
      let!(:categories) { create_list :category, 2, site: site }
      let!(:shops) { create_list :shop, 2, site: site }

      let!(:banner) { create :banner, banner_type: 'sticky_banner' }
      let!(:category_banner) { create :banner, banner_type: 'sticky_banner', categories: categories }
      let!(:shop_banner) { create :banner, banner_type: 'sticky_banner', shops: shops }
      let!(:home_banner) { create :banner, banner_type: 'sticky_banner', show_on_home_page: true, shops: shops }

      it 'only type returns the default banner' do
        expect(Banner.by_type_shop_and_category('sticky_banner')).to eq banner
      end

      it 'allow_default = false returns no default' do
        expect(Banner.by_type_shop_and_category('sticky_banner', allow_default: false)).to eq nil
      end

      it 'shop_id returns shop locations' do
        expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: shops.first.id)).to eq shop_banner
      end

      it 'category_id returns category locations' do
        expect(Banner.by_type_shop_and_category('sticky_banner', category_id: categories.first.id)).to eq category_banner
      end

      it 'shop_id and category_id prefers shop over category locations' do
        expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: shops.first.id, category_id: categories.first.id)).to eq shop_banner
      end

      it 'home banner' do
        expect(Banner.by_type_shop_and_category('sticky_banner', show_on_home_page: true)).to eq home_banner
      end

      context 'shop_id and category_id where only category matches' do

        it 'it returns default banner if show_in_shops = false' do
          Banner.update_all(show_in_shops: false)
          expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 0, category_id: categories.first.id)).to eq banner
        end

        it 'it doesnt return default banner if allow_default = false' do
          Banner.update_all(show_in_shops: false)
          expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 0, category_id: categories.first.id, allow_default: false)).to eq nil
        end

        it 'it returns category banner if show_in_shops = true' do
          Banner.update_all(show_in_shops: true)
          expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 0, category_id: categories.first.id)).to eq category_banner
        end

        it 'it returns nil if no default banner exists' do
          Banner.update_all(show_in_shops: false)
          banner.destroy #default
          expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 0, category_id: categories.first.id)).to eq nil
        end
      end

      it 'non existing shop and category locations returns the default banner' do
        shop_banner.update(shop_ids: shops.first.id, category_ids: categories.first.id)
        category_banner.update(shop_ids: shops.first.id, category_ids: categories.first.id)
        expect(Banner.by_type_shop_and_category('sticky_banner', shop_id: 0, category_id: 0)).to eq banner
      end

      context 'type' do
        let!(:sidebar_banner) { create :banner, banner_type: 'sidebar_banner' }

        it 'returns the correct type' do
          expect(Banner.by_type_shop_and_category('sidebar_banner')).to eq sidebar_banner
        end
      end
    end
  end

  context '.category_ids' do
    let!(:categories) { create_list :category, 2, site: site }
    let!(:banner) { create :banner, category_ids: categories.map(&:id) }

    it 'creates BannerLocations' do
      expect(banner.banner_locations.count).to eq(2)
    end

    it 'removes BannerLocations' do
      banner.update(category_ids: [])
      expect(banner.banner_locations.count).to eq(0)
    end
  end

  context '.shop_ids' do
    let!(:shops) { create_list :shop, 3, site: site }
    let!(:banner) { create :banner, shop_ids: shops.map(&:id) }

    it 'creates BannerLocations' do
      expect(banner.banner_locations.count).to eq(3)
    end

    it 'removes BannerLocations' do
      banner.update(shop_ids: [])
      expect(banner.banner_locations.count).to eq(0)
    end
  end
end
