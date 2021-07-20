class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!, :user_authenticated?
  before_action :set_availability, only: %i[show edit update destroy]
  skip_before_action :check_user_subscription, only: [:create, :destroy]

  # GET /availabilities or /availabilities.json
  def index
    @availabilities = Availability.all
  end

  # GET /availabilities/1 or /availabilities/1.json
  def show; end

  # GET /availabilities/new
  def new
    @availability = Availability.new
  end

  # GET /availabilities/1/edit
  def edit; end

  # POST /availabilities or /availabilities.json
  def create
    @availabilities = current_user.availabilities
    @availability = Availability.new(availability_params)
    @availability.user = current_user

    respond_to do |format|
      if @availability.save
        format.html { redirect_to demo_settings_path, notice: 'Availability was successfully updated.' }
        format.json { render :'demos/settings', status: :ok, location: @availability }
      else
        format.html { render 'demos/settings', status: :unprocessable_entity }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /availabilities/1 or /availabilities/1.json
  def update
    respond_to do |format|
      if @availability.update(availability_params)
        format.html { redirect_to @availability, notice: 'Availability was successfully updated.' }
        format.json { render :show, status: :ok, location: @availability }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /availabilities/1 or /availabilities/1.json
  def destroy
    @availability.destroy
    respond_to do |format|
      format.html { redirect_to demo_settings_path, notice: 'Availability was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_availability
    @availability = Availability.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end
end
