class UsersController < ApplicationController
  before_action :authenticate_user!, :user_authenticated?
  before_action :find_user, only: [:update, :prospect, :contacted, :demo, :followup, :closed]
  before_action :find_lead, only: [:prospect, :contacted, :demo, :followup, :closed]
  skip_before_action :authenticate_user!, only: [:update, :prospect, :contacted, :demo, :followup, :closed, :get_availability, :book_new, :get_info ]

  layout "prospect", only: [:prospect, :contacted, :demo, :followup, :closed ]

  def prospect
    get_availability
    redirect_to root_path unless @lead.stage == "prospecting"
  end

  def contacted
    get_availability
    redirect_to root_path unless @lead.stage == "contacted"
  end

  def demo
    redirect_to root_path unless @lead.stage == "demo"
  end

  def followup
    redirect_to root_path unless @lead.stage == "followup"
  end

  def closed
    redirect_to root_path unless @lead.stage == "closing"
  end

  def book_new; end

  def get_availability
    @availabilities = find_user.availabilities.order('start_time asc')
    @availabilitie_times = Availability.inbetween_data(@availabilities)
  end

  def update
    return if @user.blank?

    unless @user.update(user_params)
      flash[:error] = @user.errors.full_messages
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def user_params
    params.require(:user).permit(:zoom_link)
  end

  def find_user
    @user = User.find_by id: params[:id]
  end

  def find_lead
    @lead = Lead.find_by phone_number: params[:lead_number]
    redirect_to root_path unless @lead
  end
end
