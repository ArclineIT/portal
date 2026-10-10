class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_client_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  # Always reports success so the form cannot be used to discover accounts.
  def create
    if client = Client.find_by_email(params[:email_address])
      PasswordsMailer.reset(client).deliver_later
    end

    redirect_to new_session_path, notice: "If that email is registered, a reset link has been sent."
  end

  def edit
  end

  def update
    if @client.update(params.permit(:password, :password_confirmation))
      @client.sessions.destroy_all
      redirect_to new_session_path, notice: "Password updated. Please log in."
    else
      redirect_to edit_password_path(params[:token]), alert: @client.errors.full_messages.to_sentence
    end
  end

  private
    def set_client_by_token
      @client = Client.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Reset link is invalid or has expired."
    end
end
