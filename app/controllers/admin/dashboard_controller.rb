class Admin::DashboardController < Admin::BaseController
  def show
    @clients = Client.by_name
    @tickets = Ticket.recent.includes(:client)
    @client = Client.new
  end
end
