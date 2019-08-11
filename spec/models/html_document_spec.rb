include ApplicationHelper

describe HtmlDocument do

  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:html_document)).to be_valid
  end

  it '::forbidden_metas returns forbidden metas array' do
    expect(HtmlDocument::forbidden_metas).to match_array([
      'Heading 1',
      'Heading 2',
      'Meta Robots',
      'Meta Keywords',
      'Meta Description',
      'Meta Title',
      'Meta Title Fallback',
      'H2'
    ])
  end

  context '::allowed_import_params' do
    let(:user) { create :freelancer, sites: [site] }

    it 'returns all headers without user param' do
      expect(HtmlDocument::allowed_import_params).to match_array([
        'Heading 1',
        'Heading 2',
        'Meta Robots',
        'Meta Keywords',
        'Meta Description',
        'Meta Title',
        'Content',
        'Welcome Text',
        'Head Scripts',
        'Meta Title Fallback',
        'Header Image',
        'Mobile Header Image',
        'Header Font Color',
        'H2'
      ])
    end

    it 'returns all headers with user who can metas' do
      expect(HtmlDocument::allowed_import_params(user)).to match_array([
        'Heading 1',
        'Heading 2',
        'Meta Robots',
        'Meta Keywords',
        'Meta Description',
        'Meta Title',
        'Content',
        'Welcome Text',
        'Head Scripts',
        'Meta Title Fallback',
        'Header Image',
        'Mobile Header Image',
        'Header Font Color',
        'H2'
      ])
    end

    it 'returns only allowed headers with user who cannot metas' do
      user.can_metas = false
      expect(HtmlDocument::allowed_import_params(user)).to match_array([
        'Content',
        'Welcome Text',
        'Head Scripts',
        'Header Image',
        'Mobile Header Image',
        'Header Font Color'
      ])
    end
  end

  context '.darken_header_image?' do
    let(:hdoc) { create :html_document, header_image_dark_filter: true }

    it 'returns header_image_dark_filter' do
      expect(hdoc.header_image_dark_filter).to eq(true)
    end
  end

  context '.dynamic_meta_description' do
    let!(:shop) { create :shop, site: site, title: 'Shop Title' }
    let!(:coupon) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: true, info_discount: '10$' }
    let!(:coupon_2) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '20$' }
    let!(:coupon_3) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '30$' }
    let!(:hdoc) { create :html_document, meta_description: 'Meta Description', htmlable: shop }
    let!(:hdoc2) { create :html_document, meta_description: 'Meta Description <top_position_savings>', htmlable: shop }

    it 'returns the original meta title' do
      expect(hdoc.dynamic_meta_description).to eq('Meta Description')
    end

    it 'replaces top_position_savings' do
      expect(hdoc2.dynamic_meta_description(Coupon.active)).to eq("Meta Description 10%")
    end

    it 'replaces <coupon1_info_discount>' do
      hdoc2.meta_description = '<coupon1_info_discount>'
      expect(hdoc2.dynamic_meta_description(Coupon.active)).to eq(coupon.info_discount)
    end
  end

  context '.is_shop_or_category?' do
    it 'returns true if is shop' do
      expect(build(:html_document, htmlable_type: 'Shop').is_shop_or_category?).to eq(true)
    end
    it 'returns true if is category' do
      expect(build(:html_document, htmlable_type: 'Category').is_shop_or_category?).to eq(true)
    end
    it 'returns false if is others' do
      expect(build(:html_document, htmlable_type: 'Campaign').is_shop_or_category?).to eq(false)
    end
  end

  context '.darken_header_image?' do
    it 'returns true if header_image_dark_filter is true' do
      expect(build(:html_document, header_image_dark_filter: true).darken_header_image?).to eq(true)
    end

    it 'returns false if header_image_dark_filter is false' do
      expect(build(:html_document, header_image_dark_filter: false).darken_header_image?).to eq(false)
    end
  end

  context '.dynamic_meta_title' do
    let!(:shop) { create :shop, site: site, title: 'Shop Title' }
    let!(:coupon) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: true, info_discount: '10$'}
    let!(:coupon_2) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '20$' }
    let!(:coupon_3) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '30$' }
    let!(:hdoc) { create :html_document, meta_title: 'Meta Title', htmlable: shop }

    it 'returns the original meta title' do
      expect(hdoc.dynamic_meta_title).to eq('Meta Title')
    end

    it 'replaces <year>' do
      hdoc.meta_title = '<year>'
      expect(hdoc.dynamic_meta_title).to eq(Time.now.year.to_s)
    end

    it 'replaces <month>' do
      hdoc.meta_title = '<month>'
      expect(hdoc.dynamic_meta_title).to eq(month_number_to_word(Time.now.month.to_s))
    end

    it 'replaces <month_abbrv>' do
      hdoc.meta_title = '<month_abbrv>'
      I18n.global_scope = :backend
      expect(hdoc.dynamic_meta_title).to eq((I18n.t :abbr_month_names, :scope => :date)[Time.now.month].titleize)
    end

    it 'replaces <savings_percentage>' do
      hdoc.meta_title = '<savings_percentage>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq('10%')
    end

    it 'replaces <active_coupons_count>' do
      hdoc.meta_title = '<active_coupons_count>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq("3")
      Coupon.active.update(status: 'blocked')
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq("")
    end

    it 'replaces <top_exclusive_value>' do
      hdoc.meta_title = '<top_exclusive_value>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq('10%')
    end

    it 'replaces <shop_name>' do
      hdoc.meta_title = '<shop_name>'
      expect(hdoc.dynamic_meta_title).to eq('Shop Title')
    end

    it 'replaces <category_name>' do
      hdoc.htmlable = Category.new name: 'Category Title'
      hdoc.meta_title = '<category_name>'
      expect(hdoc.dynamic_meta_title).to eq('Category Title')
    end

    it 'replaces <campaign_name>' do
      hdoc.htmlable = Campaign.new name: 'Campaign Title'
      hdoc.meta_title = '<campaign_name>'
      expect(hdoc.dynamic_meta_title).to eq('Campaign Title')
    end

    it 'replaces <title_of_top_coupon>' do
      hdoc.meta_title = '<title_of_top_coupon>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq(coupon.title)
    end

    it 'replaces <exclusive>' do
      hdoc.meta_title = '<exclusive>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq(I18n.t(:exclusive, default: 'Exclusive'))
    end

    it 'replaces <coupon1_info_discount>' do
      hdoc.meta_title = '<coupon1_info_discount>'
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq(coupon.info_discount)
    end

    it 'replaces <coupon3_info_discount> to empty string if no value received' do
      hdoc.meta_title = '<coupon3_info_discount>'
      coupon_3.update(status: 'blocked')
      expect(hdoc.dynamic_meta_title(Coupon.active)).to eq('')
    end

    context 'returns fallback' do

      let!(:empty_shop) { create :shop, site: site }
      let!(:hdoc_fallback) { create :html_document, meta_title: 'Meta Title', meta_title_fallback: 'Fallback', htmlable: shop }

      it 'if savings_percentage blank' do
        hdoc_fallback.meta_title = '<savings_percentage>'
        expect(hdoc_fallback.dynamic_meta_title).to eq('Fallback')
      end
      it 'if top_position_savings blank' do
        hdoc_fallback.meta_title = '<top_position_savings>'
        expect(hdoc_fallback.dynamic_meta_title).to eq('Fallback')
      end
      it 'if top_exclusive_value blank' do
        hdoc_fallback.meta_title = '<top_exclusive_value>'
        expect(hdoc_fallback.dynamic_meta_title).to eq('Fallback')
      end

      it 'if top_3_coupons_discount_hash blank' do
        hdoc_fallback.meta_title = '<coupon1_info_discount>'
        expect(hdoc_fallback.dynamic_meta_title).to eq('Fallback')
      end
    end

    context '.includes_coupon_info_discount?' do
      let!(:shop) { create :shop, site: site }
      let!(:html_document_with_vars) { create :html_document, meta_title: 'Meta Title <coupon1_info_discount>', meta_title_fallback: 'Fallback',
        htmlable: shop, meta_description: 'Meta Description  <coupon2_info_discount>' }
      let!(:html_document_without_vars) { create :html_document, meta_title: 'Meta Title', meta_title_fallback: 'Fallback',
        htmlable: shop, meta_description: 'Meta Description' }

      it 'meta title includes variable' do
        expect(html_document_with_vars.send(:includes_coupon_info_discount?, html_document_with_vars.meta_title)).to eq(true)
      end

      it 'meta description includes variable' do
        expect(html_document_with_vars.send(:includes_coupon_info_discount?, html_document_with_vars.meta_description)).to eq(true)
      end

      it 'meta title does not include variable' do
        expect(html_document_without_vars.send(:includes_coupon_info_discount?, html_document_without_vars.meta_title)).to eq(false)
      end

      it 'meta description does not include variable' do
        expect(html_document_without_vars.send(:includes_coupon_info_discount?, html_document_without_vars.meta_description)).to eq(false)
      end
    end

    context '.top_3_coupons_discount_hash' do
      let!(:shop) { create :shop, site: site }
      let!(:hdoc) { create :html_document, meta_description: 'Meta Description', htmlable: shop }
      let!(:coupon) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: true, info_discount: '10$'}
      let!(:coupon_2) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '20$' }
      let!(:coupon_3) { create :coupon, shop: shop, savings_in: 'percent', savings: 10, is_exclusive: false, info_discount: '30$' }

      it 'returnes hash with variables and values' do
        hash = {
          '<coupon1_info_discount>' => '10$',
          '<coupon2_info_discount>' => '20$',
          '<coupon3_info_discount>' => '30$'
        }
        expect(hdoc.send(:top_3_coupons_discount_hash, Coupon.active)).to eq(hash)
      end

      it 'returnes empty string if no coupons' do
        Coupon.update_all(status: 'blocked')
        expect(hdoc.send(:top_3_coupons_discount_hash, Coupon.active)).to eq('')
      end

      it 'returnes hash with nil values if lack of info_discount or coupons' do
        coupon_3.update(status: 'blocked')
        expect(hdoc.send(:top_3_coupons_discount_hash, Coupon.active)['<coupon3_info_discount>']).to eq(nil)
      end
    end
  end
end
