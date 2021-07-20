# frozen_string_literal: true

class AppointmentsController < ApplicationController # rubocop:todo Style/Documentation
    # before_action :authenticate_user!, except: %i[availabilitie_time]
    before_action :set_appointment, only: %i[show edit update destroy]
    before_action :set_availability, only: %i[create]
  
    def index
      start_date = params.fetch(:start_date, Date.today).to_date
      @appointments = Appointment.includes(:assigned_to).starts_from(start_date, current_user)
      
      @availabilities = current_user.availabilities.order('start_time asc')
      @availabilitie_times = Availability.inbetween_data(@availabilities)
    end
  
    def day_view
      @start_date = params.fetch(:date, Date.today).to_date
      @appointments = Appointment.includes(:assigned_to).of_day(@start_date, current_user)
    end
  
    # GET /appointments/1 or /appointments/1.json
    def show; end
  
    # GET /appointments/new
    def new; end
  
  
    # GET /appointments/1/edit
    def edit; end
  
    # POST /appointments or /appointments.json
    def create
      @appointment = Appointment.new(appointment_params)
      @appointment.progress = 1
      assign_member
      respond_to do |format|
        if @appointment.save
          @lead = @appointment.lead
          format.js 
        else
          p @appointment.errors
          format.js
        end
      end
    end
  
    def assign_member
      availability_info
      @appointment.assigned_to = @availability.user
      @appointment.start_time = "#{@available_date} #{
                                  @available_start_time}".to_datetime
      @appointment.end_time = "#{@available_date} #{
                                  @available_end_time}".to_datetime
    end
  
    def availability_info
      @available_date = params[:availability_id].split('^#^')[3]
      @available_start_time = params[:availability_id].split('^#^')[1]
      @available_end_time = params[:availability_id].split('^#^')[2]
    end
  
    # PATCH/PUT /appointments/1 or /appointments/1.json
    def update
      respond_to do |format|
        if @appointment.update(appointment_params)
          format.html do
            flash[:notice] = 'Appointment was successfully updated.'
            redirect_back(fallback_location: root_path)
          end
          format.json { render :show, status: :ok, location: @appointment }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @appointment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def availabilitie_time
      @availabilities = Availability.service_employee_availabilities(@service).order('start_time asc')
      @availabilitie_times = Availability.inbetween_data(@availabilities, @service)
    end
  
    # updates appointment progress
    def update_appointment_progress
      @appointment_displayed_in_progress = Appointment.find_by(id: params[:appointment_id])
      @state = params[:state_number].to_i
      @appointment_displayed_in_progress.update(progress: @state)
      @appointment_displayed_in_progress.send_text_to_members(current_user)
  
      @invoice = Invoice.new
      @statuses = Invoice.new.all_statuses.to_a.map { |c| [c[1], c[0]] }
      @invoice_types = Invoice.new.all_invoice_types.to_a.map { |c| [c[1], c[0]] }
      @customer = @appointment_displayed_in_progress.customer
      respond_to do |format|
        format.js { render :update_appointment_progress }
      end
    end
  
    # get select-appointment/:id, ajax
    def select_appointment
      @appointment_displayed_in_progress = Appointment.find_by(id: params[:id])
      @customer = @appointment_displayed_in_progress.customer
      @invoice = Invoice.new
      @statuses = Invoice.new.all_statuses.to_a.map { |c| [c[1], c[0]] }
      @invoice_types = Invoice.new.all_invoice_types.to_a.map { |c| [c[1], c[0]] }
      respond_to do |format|
        format.js { render :update_appointment_progress }
      end
    end
  
    # DELETE /appointments/1 or /appointments/1.json
    def destroy
      @appointment.destroy
      respond_to do |format|
        format.html { redirect_to appointments_url, notice: 'Appointment was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find_by(id: params[:id])
    end
  
    def set_availability
      @availability = Availability.find_by(id: params[:availability_id].split('^#^')[0])
    end
  
    # Only allow a list of trusted parameters through.
    def appointment_params
      params.require(:appointment).permit(:user_id, :lead_id, :start_time,:end_time)
                                          
    end
  end
  