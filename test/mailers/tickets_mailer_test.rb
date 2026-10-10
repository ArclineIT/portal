require "test_helper"

class TicketsMailerTest < ActionMailer::TestCase
  test "created goes to the admin address with a link to the ticket" do
    ticket = tickets(:acme_outage)

    with_admin_email "ops@example.com" do
      mail = TicketsMailer.created(ticket, ticket.messages.first)

      assert_equal [ "ops@example.com" ], mail.to
      assert_equal "[Arcline Portal] New ticket: Site is slow", mail.subject
      assert_match "New support ticket from Acme Co", mail.body.encoded
      assert_match "/tickets/#{ticket.id}", mail.body.encoded
    end
  end

  test "created sends nothing when no admin address is set" do
    with_admin_email nil do
      assert_emails 0 do
        TicketsMailer.created(tickets(:acme_outage), ticket_messages(:acme_outage_first)).deliver_now
      end
    end
  end

  test "reply goes to the ticket owner, and nowhere if they have no email" do
    mail = TicketsMailer.reply(tickets(:acme_outage), ticket_messages(:acme_outage_first), clients(:admin))
    assert_equal [ "owner@acme.test" ], mail.to
    assert_match "Blake replied to your ticket", mail.body.encoded

    assert_emails 0 do
      TicketsMailer.reply(tickets(:globex_dns), ticket_messages(:globex_dns_first), clients(:admin)).deliver_now
    end
  end

  test "the password reset email links to the reset form" do
    mail = PasswordsMailer.reset(clients(:acme))

    assert_equal [ "owner@acme.test" ], mail.to
    assert_match %r{/reset/\S+}, mail.body.encoded
  end

  private
    def with_admin_email(value)
      original = ENV["ADMIN_EMAIL"]
      ENV["ADMIN_EMAIL"] = value
      yield
    ensure
      ENV["ADMIN_EMAIL"] = original
    end
end
