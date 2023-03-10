module CapybaraExt
  def page!
    save_and_open_page
  end

  def set_app_host host
    default_url_options[:host] = host
    Capybara.app_host = "http://#{host}"
  end

  def click_icon(type)
    find(".icon-#{type}").click
  end

  def eventually_fill_in(field, options={})
    page.should have_css('#' + field)
    fill_in field, options
  end

  def within_row(num, &block)
    if example.metadata[:js]
      within("table tbody tr:nth-child(#{num})", &block)
    else
      within(:xpath, all("table tbody tr")[num-1].path, &block)
    end
  end

  def thead_text(num)
    if example.metadata[:js]
      find("th:nth-child(#{num})").text
    else
      all("th")[num-1].text
    end
  end

  def column_text(num)
    if example.metadata[:js]
      find("td:nth-child(#{num})").text
    else
      all("td")[num-1].text
    end
  end

  def date_time_select(value, options)
    if value.is_a?(Time)
      select value.year, from: options[:from] + '_1i'
      select Date::MONTHNAMES[value.month], from: options[:from] + '_2i'
      select value.day, from: options[:from] + '_3i'
      select value.hour, from: options[:from] + '_4i'
      select value.min, from: options[:from] + '_5i'
    end
  end

  def set_select2_field(field, value)
    page.execute_script %Q{$('#{field}').select2('val', '#{value}')}
  end

  def select2_search(value, options)
    label = find_label_by_text(options[:from])
    within label.first(:xpath,".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end
    targetted_select2_search(value, options)
  end

  def targetted_select2_search(value, options)
    page.execute_script %Q{$('#{options[:from]}').select2('open')}
    page.execute_script "$('#{options[:dropdown_css]} input.select2-input').val('#{value}').trigger('keyup-change');"
    select_select2_result(value)
  end

  def select2(value, options)
    label = find_label_by_text(options[:from])

    within label.first(:xpath,".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end
    targetted_select2(value, options)
  end

  def select2_no_label value, options={}
    raise "Must pass a hash containing 'from'" if not options.is_a?(Hash) or not options.has_key?(:from)

    placeholder = options[:from]
    minlength = options[:minlength] || 4

    click_link placeholder

    select_select2_result(value)
  end

  def targetted_select2(value, options)
    # find select2 element and click it
    find(options[:from]).find('a').click
    select_select2_result(value)
  end

  def select_select2_result(value)
    # results are in a div appended to the end of the document
    within(:xpath, '//body') do
      page.find("div.select2-result-label", text: %r{#{Regexp.escape(value)}}i).click
    end
  end

  def find_label_by_text(text)
    label = find_label(text)
    counter = 0

    # Because JavaScript testing is prone to errors...
    while label.nil? && counter < 10
      sleep(1)
      counter += 1
      label = find_label(text)
    end

    if label.nil?
      raise "Could not find label by text #{text}"
    end

    label
  end

  def find_label(text)
    first(:xpath, "//label[text()[contains(.,'#{text}')]]")
  end

  # drags an item to a destination, just pass selectors like #widgets li:first-child
  def drag_item_to item, destination
    item = page.find(item)
    destination = page.find(destination)
    item.drag_to(destination)
    wait_for_ajax
  end

  def wait_for_ajax
    counter = 0
    while page.evaluate_script("typeof($) === 'undefined' || $.active > 0")
      counter += 1
      sleep(0.1)
      raise "AJAX request took longer than 5 seconds." if counter >= 50
    end
  end

  def handle_js_confirm(accept=true)
    page.evaluate_script "window.original_confirm_function = window.confirm"
    page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
    yield
  ensure
    page.evaluate_script "window.confirm = window.original_confirm_function"
  end

  def accept_alert
    page.evaluate_script('window.confirm = function() { return true; }')
    yield
  end

  def dismiss_alert
    page.evaluate_script('window.confirm = function() { return false; }')
    yield
    # Restore existing default
    page.evaluate_script('window.confirm = function() { return true; }')
  end
end

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

RSpec::Matchers.define :have_meta do |name, expected|
  match do |actual|
    has_css?("meta[name='#{name}'][content='#{expected}']", visible: false)
  end

  failure_message_for_should do |actual|
    actual = first("meta[name='#{name}']")
    if actual
      "expected that meta #{name} would have content='#{expected}' but was '#{actual[:content]}'"
    else
      "expected that meta #{name} would exist with content='#{expected}'"
    end
  end
end

RSpec::Matchers.define :have_title do |expected|
  match do |actual|
    has_css?("title", :text => expected, visible: false)
  end

  failure_message_for_should do |actual|
    actual = first("title")
    if actual
      "expected that title would have been '#{expected}' but was '#{actual.text}'"
    else
      "expected that title would exist with '#{expected}'"
    end
  end
end

RSpec.configure do |c|
  c.include CapybaraExt
end
