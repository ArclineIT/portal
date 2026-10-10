class DashboardController < ApplicationController
  def show
    @statuses = UptimeReader.statuses_for(Current.client.monitors.ordered.to_a)
    @domains = Current.client.domains.by_name
    @tickets = Current.client.tickets.recent.limit(5)
  end
end
