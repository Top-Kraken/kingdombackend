class LeadsController < ApplicationController
  before_action :user_authenticated?
  before_action :set_lead, only: %i[show edit update change_stage destroy]
  before_action :set_leads, only: %i[pipeline_view]
  def index
    @current_user = User.first
    @leads = @current_user.leads
  end

  # GET /lead_view
  def lead_view
    @lead = Lead.last
    @leads = Lead.all
  end

  # GET /pipeline_view
  def pipeline_view
    @leads = Lead.search(params[:query]) if params[:query]
  end

  # GET /leads/new
  def new
    @lead = Lead.new
    p @lead
  end

  # GET /leads/1/edit
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads or /leads.json
  def create
    @current_user = User.first
    @lead = @current_user.leads.create(lead_params)
    respond_to do |format|
      if @lead.save
        format.html { redirect_to leads_url, notice: 'Lead was successfully created.' }
        format.json { render :show, status: :created, location: @lead }
      else
        format.html { render js: @lead.errors, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def import
    # @current_user should be deleted after adding the functionality for user to sign-in

    @current_user = User.first
    @import = Lead.import(@current_user, params[:file])
    @leads  = Lead.last_created
    respond_to do |format|
      if @leads
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leads/1 or /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params)
        format.html { redirect_to leads_url, notice: 'Lead was successfully updated.' }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.js
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_stage
    @lead.update(stage: params[:lead][:stage].to_s) if params.dig(:lead, :stage)
  end

  # DELETE /leads/1 or /leads/1.json
  def destroy
    @lead.destroy
    respond_to do |format|
      format.html { redirect_to leads_url, notice: 'Lead was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lead
    @lead = Lead.find(params[:id])
  end

  def set_leads
    @leads = Lead.all
  end

  # Only allow a list of trusted parameters through.
  def lead_params
    params.require(:lead).permit(:first_name, :phone_number, :last_name, :facebook, :instagram, :linkedin)
  end
end
