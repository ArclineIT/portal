class Admin::MonitorsController < Admin::BaseController
  before_action :set_client

  def create
    monitor = @client.monitors.new(params.permit(:monitor_name, :label))
    flash[:alert] = monitor.errors.full_messages.to_sentence unless monitor.save
    redirect_to admin_client_path(@client)
  end

  def destroy
    @client.monitors.find(params[:id]).destroy
    redirect_to admin_client_path(@client), status: :see_other
  end

  private
    def set_client
      @client = Client.find(params[:client_id])
    end
end
