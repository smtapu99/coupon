RedirectRule.class_eval do

  attr_accessor :site_id

  after_find :find_site_id_by_hostname

  before_validation :sanitize_source_and_destination #0

  before_validation :add_environment_rule #1

  validates_presence_of :site_id

  validate :presence_of_hostname

  validate :uniqueness_of_source_by_hostname

  validate :source_and_destination_start_with_slash

  def self.match_for(source, environment)
    match_scope = where(match_sql_condition.strip, { true: true, false: false, source: source })
    match_scope = match_scope.order(source_is_regex: :asc)
    match_scope = match_scope.includes(:request_environment_rules)
    match_scope = match_scope.references(:request_environment_rules) if Rails.version.to_i == 4
    match_scope.detect do |rule|
      rule.request_environment_rules.all? { |env_rule| env_rule.matches?(environment) }
    end
  end

  def self.destination_for(source, environment)
    rule = match_for(source, environment)
    rule.evaluated_destination_for(source) if rule
  end

  def self.grid_filter(params)
    hostname = Site.find(params[:site_id]).hostname

    query = includes(:request_environment_rules)
    query = query.where(request_environment_rules: { environment_value: hostname })
    query = query.where('source like ?', "%#{params[:source]}%") if params[:source].present?
    query = query.where('destination like ?', "%#{params[:destination]}%") if params[:destination].present?

    if params[:active] == 'active'
      query = query.where(active: true)
    elsif params[:active] == 'blocked'
      query = query.where(active: false)
    end

    query
  end

  def find_site_id_by_hostname
    site = Site.find_by(hostname: env_hostname) if env_hostname
    self.site_id = site.present? ? site.id : destroy_redirect_rule
  end

  # make sure a redirect rule is always valid for a site_id otherwise destroy the rule
  def destroy_redirect_rule
    destroy #and raise 'Redirection Rule cannot be matched with an existing site"; Redirection destroyed!'
  end

  def env_hostname
    @env_hostname ||= self.request_environment_rules.first.environment_value if self.request_environment_rules.present?
  end

  def sanitize_source_and_destination
    self.source.strip! if self.source.present?
    self.destination.strip! if self.destination.present?
  end

  def add_environment_rule
    if new_record? && self.request_environment_rules.blank?
      site = Site.find(site_id)
      @hostname = site.hostname
      self.request_environment_rules << RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME', environment_value: site.hostname)
    end
  end

  def presence_of_hostname
    if self.request_environment_rules.blank? || self.request_environment_rules.first.environment_value.blank?
      errors.add(:site_id, 'is missing. Please define a valid site_id with hostname defined')
    end
  end

  def uniqueness_of_source_by_hostname
    errors.add(:source, 'already exists as redirect rule for this site; please consider updating that') if source_present_for_hostname
  end

  def source_present_for_hostname
    RequestEnvironmentRule.joins(:redirect_rule).where(environment_value: @hostname, redirect_rules: {source: self.source}).any?
  end

  def source_and_destination_start_with_slash
    message = "needs to start with a / and has to be a relative path like /top-coupons or a valid REGEX"
    errors.add(:source, message) unless self.source.start_with?("/")
    errors.add(:destination, message) unless self.destination.start_with?("/")
  end

end
