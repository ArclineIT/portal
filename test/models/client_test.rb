require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "requires a username, display name and an eight character password" do
    assert_not Client.new(username: "", display_name: "X", password: "password123").valid?
    assert_not Client.new(username: "x", display_name: "", password: "password123").valid?
    assert_not Client.new(username: "x", display_name: "X", password: "short").valid?
    assert Client.new(username: "x", display_name: "X", password: "password123").valid?
  end

  test "usernames are unique" do
    assert_not Client.new(username: "acme", display_name: "Other", password: "password123").valid?
  end

  test "find_by_email never matches clients without an email" do
    assert_equal clients(:acme), Client.find_by_email(" Owner@Acme.test ")
    assert_nil Client.find_by_email("")
    assert_nil Client.find_by_email(nil)
  end

  test "deleting a client removes everything they own" do
    assert_difference -> { Domain.count } => -1, -> { Ticket.count } => -1, -> { TicketMessage.count } => -1 do
      clients(:acme).destroy
    end
  end
end
