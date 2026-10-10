require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:acme)
    sign_in_as @client
  end

  test "shows the settings page" do
    get settings_path
    assert_response :success
  end

  test "updates the email" do
    patch settings_email_path, params: { email_address: " New@Acme.test " }

    assert_equal "new@acme.test", @client.reload.email_address
  end

  test "refuses a blank email" do
    patch settings_email_path, params: { email_address: " " }

    assert_equal "Email cannot be empty.", flash[:alert]
    assert_equal "owner@acme.test", @client.reload.email_address
  end

  test "changes the password when the current one is right" do
    patch settings_password_path, params: { current_password: "password123", password: "new-password-1", password_confirmation: "new-password-1" }

    assert_equal "Password changed.", flash[:notice]
    assert @client.reload.authenticate("new-password-1")
  end

  test "refuses a wrong current password, a short password, or a mismatch" do
    patch settings_password_path, params: { current_password: "wrong", password: "new-password-1", password_confirmation: "new-password-1" }
    assert_equal "Current password is incorrect.", flash[:alert]

    patch settings_password_path, params: { current_password: "password123", password: "short", password_confirmation: "short" }
    assert_match "too short", flash[:alert]

    patch settings_password_path, params: { current_password: "password123", password: "new-password-1", password_confirmation: "other" }
    assert_match "doesn't match", flash[:alert]

    assert @client.reload.authenticate("password123")
  end
end
