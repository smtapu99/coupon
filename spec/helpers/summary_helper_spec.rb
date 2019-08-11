describe SummaryHelper do
  include RSpecHtmlMatchers

  let!(:site) { create :site }
  let!(:coupon) { create :coupon, site: site, savings: 10, savings_in: 'percentage' }

  context '.summary' do
    before { helper.summarize_coupons(coupon, 0) }

    it 'returns @best' do
      expect(helper.summary(:best)).to be_a(SummaryHelper::BestCollector)
    end
    it 'returns @counts' do
      expect(helper.summary(:counts)).to be_a(SummaryHelper::CountCollector)
    end
  end

  context '.anchorize_title' do
    context 'with publisher_site.anchors_for_summary_widget = true' do
      let!(:setting) { create :setting, publisher_site: { anchors_for_summary_widget: 1 }, site: site }
      before { Site.current = site }
      subject { helper.anchorize_title('Title', '#1')}
      it { is_expected.to have_tag(:a, href: '#1', text: 'Title') }
    end

    context 'with publisher_site.anchors_for_summary_widget = false' do
      let!(:setting) { create :setting, publisher_site: { anchors_for_summary_widget: 0 }, site: site }
      before { Site.current = site }
      subject { helper.anchorize_title('Title', '#1')}
      it { is_expected.to eq 'Title' }
    end
  end

  context '.summarize_coupons' do
    it 'assigns last_updated' do
      helper.summarize_coupons(coupon, 0)
      expect(helper.summary(:best).last_updated).to eq(coupon)
    end

    it 'assigns top if index == 0' do
      helper.summarize_coupons(coupon, 0)
      expect(helper.summary(:best).top).to eq(coupon)
    end

    it 'assigns free_delivery if index != 0' do
      coupon.update(is_free_delivery: true)
      helper.summarize_coupons(coupon, 1)
      expect(helper.summary(:best).free_delivery).to eq(coupon)
    end

    it 'assigns percentage if index != 0' do
      coupon.update(savings_in: 'percent')
      helper.summarize_coupons(coupon, 0)
      expect(helper.summary(:best).percentage).to eq(nil)

      helper.summarize_coupons(coupon, 1)
      expect(helper.summary(:best).percentage).to eq(coupon)
    end

    it 'assigns currency if index != 0 and !is_best_percentage?' do
      coupon.update(savings_in: 'percent')
      helper.summarize_coupons(coupon, 1)
      expect(helper.summary(:best).currency).to eq(nil)

      coupon.update(savings_in: 'currency')
      helper.summarize_coupons(coupon, 1)
      expect(helper.summary(:best).currency).to eq(coupon)
    end
  end

  context 'BestCollector' do
    context '.keys' do
      subject { SummaryHelper::BestCollector.new.keys }
      it { is_expected.to eq(SummaryHelper::BestCollector::KEYS) }
    end

    context '.coupon' do
      subject do
        collector = SummaryHelper::BestCollector.new
        collector.top = 'top'
        collector.coupon(:top)
      end
      it { is_expected.to eq('top') }
    end

    context '.discount' do
      context 'currency' do
        let(:coupon) { create :coupon, savings_in: 'currency', savings: '10' }

        subject do
          collector = SummaryHelper::BestCollector.new
          collector.currency = coupon
          collector.discount
        end
        it { is_expected.to eq(coupon.savings_in_string(false)) }
      end

      context 'percentage' do
        let(:coupon) { create :coupon, savings_in: 'percent', savings: '10' }

        subject do
          collector = SummaryHelper::BestCollector.new
          collector.percentage = coupon
          collector.discount
        end
        it { is_expected.to eq(coupon.savings_in_string(false)) }
      end
    end
  end

  context 'CountCollector' do
    context '.keys' do
      subject { SummaryHelper::CountCollector.new.keys }
      it { is_expected.to eq(SummaryHelper::CountCollector::KEYS) }
    end

    context '.count' do
      subject do
        collector = SummaryHelper::CountCollector.new
        collector.increment(:coupon)
        collector.count(:coupon)
      end
      it { is_expected.to eq(1) }
    end

    context '.value_of_interest?' do
      context 'total' do
        context 'if 0' do
          subject do
            collector = SummaryHelper::CountCollector.new
            collector.value_of_interest?(:total)
          end
          it { is_expected.to eq(false) }
        end

        context 'if > 0' do
          subject do
            collector = SummaryHelper::CountCollector.new
            collector.increment(:total)
            collector.value_of_interest?(:total)
          end
          it { is_expected.to eq(true) }
        end
      end

      context 'other keys' do
        let(:coupon) { create :coupon }

        context 'if count = 0' do
          subject do
            collector = SummaryHelper::CountCollector.new
            collector.set_coupon(:coupon, coupon)
            collector.value_of_interest?(:coupon)
          end
          it { is_expected.to eq(false) }
        end

        context 'if coupon.blank?' do
          subject do
            collector = SummaryHelper::CountCollector.new
            collector.increment(:coupon)
            collector.value_of_interest?(:coupon)
          end
          it { is_expected.to eq(false) }
        end

        context 'if count > 0 and coupon.present?' do
          subject do
            collector = SummaryHelper::CountCollector.new
            collector.increment(:coupon)
            collector.set_coupon(:coupon, coupon)
            collector.value_of_interest?(:coupon)
          end
          it { is_expected.to eq(true) }
        end
      end
    end
  end
end
