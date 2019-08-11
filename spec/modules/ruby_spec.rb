describe 'Ruby' do
  context 'Integer' do
    it '.to_b?' do
      expect(1.to_b?).to eq(true)
      expect(0.to_b?).to eq(false)
    end
  end

  context 'Array' do
    context '.except' do
      let(:array) { ['a', 'b'] }
      subject { array.except('b') }
      it { is_expected.to eq(['a']) }
    end

    context '.keys_with_highest_frequency' do
      let(:array) { [1,2,2,3,3,3,'a','a','a'] }
      subject { array.keys_with_highest_frequency }
      it { is_expected.to eq({ 3 => 3, 'a' => 3 }) }
    end
  end

  context 'String' do
    it '.rtrim' do
      expect('MyString'.rtrim('g')).to eq('MyStrin')
    end

    it '.rtrim!' do
      expect('MyString'.rtrim!('g')).to eq('MyStrin')
    end

    it '.ltrim' do
      expect('MyString'.ltrim('M')).to eq('yString')
    end

    it '.ltrim!' do
      expect('MyString'.ltrim!('M')).to eq('yString')
    end

    it '.ucfirst' do
      expect('myString'.ucfirst).to eq('MyString')
    end

    it '.is_i?' do
      expect('1'.is_i?).to eq(true)
      expect('a'.is_i?).to eq(false)
    end

    it '.is_number?' do
      expect('1.0'.is_number?).to eq(true)
      expect('a'.is_number?).to eq(false)
    end

    it '.to_slug' do
      expect('My String'.to_slug).to eq('my-string')
    end

    it '.sanitize_as_filename' do
      expect('My String'.sanitize_as_filename).to eq('my-string')
    end

    it '.transliterate' do
      expect('-‐‒–—―⁃−­'.transliterate).to eq('---------')
    end

    it '.underscore' do
      expect('MyString'.underscore).to eq('my_string')
    end
  end

  context 'OpenStruct' do
    it '.marshal_dump_recursive' do
      o = OpenStruct.new
      o.a = 'a'
      o.b = { c: 'c' }
      expect(o.marshal_dump_recursive).to eq(a: 'a', b: { c: 'c' })
    end
  end

  context 'Hash' do
    it '.to_ostruct_recursive' do
      h = { a: 'a', b: { c: 'c' } }
      expect(h.to_ostruct_recursive).to be_a(OpenStruct)
      expect(h.to_ostruct_recursive.b).to be_a(OpenStruct)
    end
  end
end
