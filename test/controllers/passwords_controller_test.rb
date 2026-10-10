require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "emails a reset link to a known address" do
    assert_enqueued_emails 1 do
      post passwords_path, params: { email_address: "owner@acme.test" }
    end
    assert_redirected_to new_session_path
  end

  test "gives the same answer for an unknown or blank address" do
    assert_no_enqueued_emails do
      post passwords_path, params: { email_address: "nobody@example.com" }
      post passwords_path, params: { email_address: "" }
    end
    assert_redirected_to new_session_path
    assert_equal "If that email is registered, a reset link has been sent.", flash[:notice]
  end

  test "sets a new password with a valid token and signs out old sessions" do
    client = clients(:acme)
    client.sessions.create!

    patch password_path(client.password_reset_token), params: { password: "new-password-1", password_confirmation: "new-password-1" }

    assert_redirected_to new_session_path
    assert client.reload.authenticate("new-password-1")
    assert_empty client.sessions
  end

  test "rejects a mismatched confirmation" do
    client = clients(:acme)
    token = client.password_reset_token

    patch password_path(token), params: { password: "new-password-1", password_confirmation: "different" }

    assert_redirected_to edit_password_path(token)
    assert client.reload.authenticate("password123")
  end

  test "rejects an invalid or expired token" do
    get edit_password_path("garbage")
    assert_redirected_to new_password_path

    token = clients(:acme).password_reset_token
    travel 61.minutes do
      get edit_password_path(token)
      assert_redirected_to new_password_path
    end
  end
end
