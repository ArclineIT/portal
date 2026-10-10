class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[ show reply ]

  def index
    @tickets = Current.client.tickets.recent
  end

  def show
    @messages = @ticket.messages
  end

  def create
    subject, body = params[:subject].to_s.strip, params[:body].to_s.strip
    return redirect_to tickets_path, alert: "Subject and message are required." if subject.blank? || body.blank?

    ticket = Ticket.open_for(Current.client, subject: subject, body: body)
    TicketsMailer.created(ticket, ticket.messages.first).deliver_later
    redirect_to ticket_path(ticket)
  end

  def reply
    body = params[:body].to_s.strip
    return redirect_to ticket_path(@ticket) if body.blank?

    admin = Current.client.admin?
    message = @ticket.reply!(body, from_admin: admin, close: admin && params[:close] == "1")

    if admin
      TicketsMailer.reply(@ticket, message, Current.client).deliver_later
    else
      TicketsMailer.created(@ticket, message, reply: true).deliver_later
    end
    redirect_to ticket_path(@ticket)
  end

  private
    # Admins can open any ticket; clients only their own.
    def set_ticket
      scope = Current.client.admin? ? Ticket.all : Current.client.tickets
      @ticket = scope.find(params[:id])
    end
end
