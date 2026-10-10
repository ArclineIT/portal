class Admin::ClientsController < Admin::BaseController
  before_action :set_client, only: %i[ show destroy ]

  def show
    @monitors = @client.monitors.ordered
    @domains = @client.domains.by_name
  end

  def create
    client = Client.new(params.permit(:username, :display_name, :email_address, :password))
    client.admin = params[:admin] == "1"

    if params[:password].to_s.length >= Client::MIN_PASSWORD_LENGTH && client.save
      redirect_to admin_root_path, notice: "#{client.display_name} created."
    else
      client.errors.add(:password, "is too short (minimum is #{Client::MIN_PASSWORD_LENGTH} characters)") if client.errors.empty?
      redirect_to admin_root_path, alert: client.errors.full_messages.to_sentence
    end
  end

  def destroy
    return redirect_to admin_root_path, alert: "You cannot delete your own account." if @client == Current.client

    @client.destroy
    redirect_to admin_root_path, status: :see_other
  end

  private
    def set_client
      @client = Client.find(params[:id])
    end
end
