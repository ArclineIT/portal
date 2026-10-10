class SettingsController < ApplicationController
  def show
  end

  def update_email
    email = params[:email_address].to_s.strip
    return redirect_to settings_path, alert: "Email cannot be empty." if email.blank?

    Current.client.update!(email_address: email)
    redirect_to settings_path, notice: "Email updated."
  end

  def update_password
    client = Current.client

    if !client.authenticate(params[:current_password].to_s)
      redirect_to settings_path, alert: "Current password is incorrect."
    elsif client.update(password: params[:password].to_s, password_confirmation: params[:password_confirmation].to_s)
      redirect_to settings_path, notice: "Password changed."
    else
      redirect_to settings_path, alert: client.errors.full_messages.to_sentence
    end
  end
end
