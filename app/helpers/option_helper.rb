module OptionHelper
  # returns options by given string, 2 levels are allowed f.e. 'option.value'
  # @param  value [String]
  #
  # @return [OpenStruct]
  def get_option value, opts={}
    raise 'Invalid Format; Please use "." for method chaining' if value.include? '/'
    raise 'Uninitialized Settings, pls make sure @settings is defined' unless @settings.present?
    raise 'Deprecated method OptionHelper::get_option; use Setting::get instead' if Rails.env.development?

    Setting::get(value, opts)
  end

  def option_exists? value
    Setting::get(value) ? true : false
  end

  def gtm_container_ids
    @gtm_container_ids ||= [Setting.get('tracking.google_tag_manager_id'), Setting.get('tracking.client_google_tag_manager_id')].select(&:present?)
  end

  private

  def remove_params(url)
    url.split('?').first unless url.nil?
  end
end
