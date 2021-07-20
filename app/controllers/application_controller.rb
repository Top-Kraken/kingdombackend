class ApplicationController < ActionController::Base
  # protect_from_forgery
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def user_not_authorized
    flash[:alert] = I18n.t('pundit_not_authorized')
    redirect_to(request.referrer || root_path)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name phone_number])
    devise_parameter_sanitizer.permit :sign_in, keys: %i[phone_number password]
    devise_parameter_sanitizer.permit(:account_update, keys: %i[full_name phone_number send_text_notifications])
  end

  def after_sign_in_path_for(resource)
    if resource.status.eql?('inactive')
      confirm_phone_path
    else
      root_path
    end
  end

  def user_authenticated?
    if current_user.present? && current_user.status.eql?('inactive')
      redirect_to confirm_phone_path
    else
      root_path
    end
  end
end
