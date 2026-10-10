require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "open_for creates the ticket with its first message" do
    ticket = Ticket.open_for(clients(:acme), subject: " Help ", body: "It broke")

    assert_equal "Help", ticket.subject
    assert_equal "open", ticket.status
    assert_equal [ "It broke" ], ticket.messages.map(&:body)
    assert_not ticket.messages.first.from_admin?
  end

  test "open_for leaves nothing behind when the message is blank" do
    assert_no_difference -> { Ticket.count } do
      assert_raises(ActiveRecord::RecordInvalid) { Ticket.open_for(clients(:acme), subject: "Help", body: " ") }
    end
  end

  test "reply! adds a message, touches the ticket and can close it" do
    ticket = tickets(:acme_outage)
    ticket.update_columns(updated_at: 2.days.ago)

    ticket.reply!("Looking into it", from_admin: true)
    assert_equal "open", ticket.status
    assert ticket.updated_at > 1.minute.ago

    ticket.reply!("Fixed", from_admin: true, close: true)
    assert ticket.closed?
    assert_equal 3, ticket.messages.count
  end
end
