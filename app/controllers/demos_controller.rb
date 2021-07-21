class DemosController < ApplicationController
  before_action :authenticate_user!, :user_authenticated?
  before_action :set_demo, only: %i[show edit update destroy send_reminder]
  skip_before_action :check_user_subscription, only: [:settings]

  # GET /demos
  def index
    start_date = params.fetch(:start_date, Date.today).to_date
    current_user_appointments = current_user.appointments.includes(:lead)
    @appointments = current_user_appointments.month(start_date)
    @next_four_days = current_user_appointments.next_four_days DateTime.now
  end

  # GET /demos/settings
  def settings
    @availabilities = current_user.availabilities
    @lead = current_user.leads.first
  end

  # POST /demos/:demo_id/send_reminder
  def send_reminder
    lead = @demo.lead
    text = "Hi #{lead.first_name}, here is the zoom link for the demo #{current_user.zoom_link}"
    if TwilioClient.new.send_text(lead.phone_number, text).sid.present?
      flash[:notice] = 'Reminder was sent successfully.'
    else
      flash[:alert] = 'Something went wrong while sending reminder. Please try again later.'
    end
    redirect_back fallback_location: root_path
  end

  # GET /prospect_chat_with/:customer_phone_number
  def prospect; end

  def contacted; end

  # GET /demos/1 or /demos/1.json
  def show; end

  # GET /demos/new
  def new
    @demo = Demo.new
  end

  # GET /demos/1/edit
  def edit; end

  # POST /demos
  def create
    @demo = Demo.new(demo_params)

    respond_to do |format|
      if @demo.save
        format.html { redirect_to @demo, notice: 'Demo was successfully created.' }
        format.json { render :show, status: :created, location: @demo }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @demo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /demos/1 or /demos/1.json
  def update
    respond_to do |format|
      if @demo.update(demo_params)
        format.html { redirect_to @demo, notice: 'Demo was successfully updated.' }
        format.json { render :show, status: :ok, location: @demo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @demo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /demos/1 or /demos/1.json
  def destroy
    @demo.destroy
    respond_to do |format|
      format.html { redirect_to demos_url, notice: 'Demo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_demo
    @demo = Demo.find(params[:id] || params[:demo_id])
  end

  # Only allow a list of trusted parameters through.
  def demo_params
    params.require(:demo).permit(:user_id, :lead_id, :start_datetime)
  end
end
