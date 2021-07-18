class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [:verify_otp]

  def confirm_phone; end

  # User invitation through token
  def new
    build_resource
    yield resource if block_given?
    # resource.invite_member_token = params[:invite_member_token]
    respond_with resource
  end

  # User creation with and without invitation
  def create
    if params[:user][:invite_member_token]
      build_resource(sign_up_params.merge!(invite_member_token: params[:user][:invite_member_token]))
    else
      build_resource(sign_up_params)
    end
    resource.save
    yield resource if block_given?

    # Move inside this if statement if record is saved to db

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up

        # Move inside this if statement if record is saved to db

        if params[:user][:invite_member_token].present?
          user_invitation = UserInvitation.where(phone_number: resource.phone_number,
                                                 status: 0).order('created_at').last
          # Check if invitation exists
          if user_invitation
            subscribed_by = UserSubscription.find_by(user_id: user_invitation.user_id)
            check_subscription = UserSubscription.find_by(id: resource.id)
            # Verification step to check if user has a subscription
            if check_subscription.present?
              resource.destroy
              flash[:notice] = 'User already subscribed'
              redirect_to root_path
              return false
            end
            # Wrapping inside transaction block to handle failure in case any part is missing
            # then everything will get rolled back destroying resource seperately because it is already created
            member = Member.find_by(user_invitation_id: user_invitation.id)
            ActiveRecord::Base.transaction do
              UserSubscription.create!(user_id: resource.id, status: true, stripe_subs: subscribed_by.stripe_subs)
              member.user_id = resource.id
              member.status = 1
              member.save
              added_token = SecureRandom.alphanumeric(20)
              user_invitation.update!(status: 1, token: added_token)
            end
            if member.errors.present? || member.blank?
              resource.destroy
              return false
            end
          else
            resource.destroy
            flash[:notice] = 'Invitation Expired or already invited'
            redirect_to root_path
            return false
          end
        end
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else

        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def add_domain; end

  def search_domain
    @domains = EnomClient.new.search_keywords(params[:registration][:search])
    respond_to do |format|
      format.js
    end
  end

  def select_domain
    user = current_user
    unless user.domain.present?
      domain = EnomClient.new.register_domain(params[:domain], current_user)
      puts '******************* ENOM DOMAIN REGISTER RESPONSE *******************'
      puts domain
      # domain_name = domain.try(:first).dig 'AddBulkDomains', 'Item', 'ItemName'
      current_user.update(domain: params[:domain])
    end
    redirect_to root_path
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

  protected

  def after_sign_up_path_for(_resource)
    otp = (SecureRandom.random_number(9e5) + 1e5).to_i
    session[:otp] = otp
    sms = "Confirmation code #{otp}"
    puts "OTPPPP ++++>>>      #{sms}"
    TwilioClient.new.send_text(resource.phone_number, sms)
    flash[:notice] = ''
    confirm_phone_path
  end
end
