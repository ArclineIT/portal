require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "a client sees only their own tickets" do
    sign_in_as clients(:acme)

    get tickets_path
    assert_select "td", text: "Site is slow"
    assert_select "td", text: "DNS question", count: 0

    get ticket_path(tickets(:globex_dns))
    assert_response :not_found
  end

  test "opening a ticket notifies the admin" do
    sign_in_as clients(:acme)

    assert_enqueued_emails 1 do
      assert_difference -> { Ticket.count } => 1, -> { TicketMessage.count } => 1 do
        post tickets_path, params: { subject: "Email down", body: "Cannot send mail" }
      end
    end
    assert_redirected_to ticket_path(Ticket.order(:id).last)
  end

  test "a ticket needs a subject and a message" do
    sign_in_as clients(:acme)

    assert_no_difference -> { Ticket.count } do
      post tickets_path, params: { subject: "Email down", body: " " }
    end
    assert_equal "Subject and message are required.", flash[:alert]
  end

  test "a client reply is not marked as from the admin and cannot close the ticket" do
    sign_in_as clients(:acme)
    ticket = tickets(:acme_outage)

    post reply_ticket_path(ticket), params: { body: "Any update?", close: "1" }

    assert_not ticket.messages.last.from_admin?
    assert_equal "open", ticket.reload.status
  end

  test "an admin can reply to and close any ticket" do
    sign_in_as clients(:admin)
    ticket = tickets(:acme_outage)

    assert_enqueued_emails 1 do
      post reply_ticket_path(ticket), params: { body: "Fixed the cache.", close: "1" }
    end

    assert ticket.messages.last.from_admin?
    assert ticket.reload.closed?
  end

  test "a client cannot reply to another client's ticket" do
    sign_in_as clients(:acme)

    assert_no_difference -> { TicketMessage.count } do
      post reply_ticket_path(tickets(:globex_dns)), params: { body: "hello" }
    end
    assert_response :not_found
  end
end
