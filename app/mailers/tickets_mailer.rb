class TicketsMailer < ApplicationMailer
  # Tells the admin about a new ticket, or a client's reply to an existing one.
  def created(ticket, message, reply: false)
    return if admin_email.blank?

    @ticket, @message = ticket, message
    subject = reply ? "Re: #{ticket.subject}" : ticket.subject
    mail subject: "[Arcline Portal] New ticket: #{subject}", to: admin_email
  end

  # Tells the ticket's owner that an admin replied.
  def reply(ticket, message, replier)
    return if ticket.client.email_address.blank?

    @ticket, @message, @replier = ticket, message, replier
    mail subject: "[Arcline Portal] Re: #{ticket.subject}", to: ticket.client.email_address
  end

  private
    def admin_email
      ENV["ADMIN_EMAIL"]
    end
end
