require 'vue_data/redirect_rule'

module Admin
  class RedirectRulesController < BaseController
  before_action :set_redirect_rule, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /admin/redirect_rules
  # GET /admin/redirect_rules.json
  def index
    respond_to do |format|
      format.json { render json: VueData::RedirectRule.render_json(Site.current.id, params), status: :ok }
      format.html
    end
  end

  # GET /admin/redirect_rules/1
  # GET /admin/redirect_rules/1.json
  def show
  end

  # GET /admin/redirect_rules/new
  def new
    @redirect_rule = RedirectRule.new
  end

  # GET /admin/redirect_rules/1/edit
  def edit
  end

  # POST /admin/redirect_rules
  # POST /admin/redirect_rules.json
  def create
    @redirect_rule = RedirectRule.new(redirect_rule_params.merge(site_id: Site.current.id))
    @redirect_rule.source_is_case_sensitive = true
    respond_to do |format|
      if @redirect_rule.save
        format.html { redirect_to admin_redirect_rules_url, notice: 'Redirect rule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @redirect_rule }
      else
        format.html { render action: 'new' }
        format.json { render json: @redirect_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/redirect_rules/1
  # PATCH/PUT /admin/redirect_rules/1.json
  def update
    respond_to do |format|
      if @redirect_rule.update(redirect_rule_params.merge(site_id: Site.current.id))
        format.html { redirect_to admin_redirect_rules_url, notice: 'Redirect rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @redirect_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/redirect_rules/1
  # DELETE /admin/redirect_rules/1.json
  def destroy
    @redirect_rule.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_redirect_rule
      @redirect_rule = RedirectRule.includes(:request_environment_rules).where(request_environment_rules: {environment_value: Site.current.hostname}).find_by(id: params[:id]) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def redirect_rule_params
      params[:redirect_rule]
    end
  end
end
