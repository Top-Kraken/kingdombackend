# frozen_string_literal: true

class PasswordsController < Devise::PasswordsController
  def create
    phone_number = params[:user][:phone_number]
    user = User.find_by(phone_number: phone_number)
    if user.present?
      auth_token = SecureRandom.alphanumeric(20)
      user.update(reset_password_token: auth_token)
      sms = "Password reset link: #{edit_user_password_url(reset_password_token: auth_token)}"
      begin
        TwilioClient.new.send_text(params[:user][:phone_number], sms)
      rescue StandardError => e
        render plain: e and return
      end
      render plain: 'Password reset link sent on your phone number'
    else
      render plain: 'User not found!'
    end
  end

  def edit
    user = User.find_by(reset_password_token: params[:reset_password_token])
    if user.present?
      self.resource = user
    else
      redirect_to new_user_session_path, notice: 'Invalid reset password link'
    end
  end

  def update
    user = User.find_by(reset_password_token: params[:user][:reset_password_token])
    msg = 'Password could not be reset'
    if user.present? && params[:user][:password] == params[:user][:password_confirmation]
      user.update(password: params[:user][:password])
      msg = 'Password updated successfully!'
    end
    redirect_to new_user_session_path, notice: msg
  end
end
