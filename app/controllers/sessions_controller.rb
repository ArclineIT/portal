class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if client = Client.authenticate_by(username: params[:username].to_s.strip, password: params[:password].to_s)
      start_new_session_for client
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Invalid username or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
