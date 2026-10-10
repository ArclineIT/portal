require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "pages require a login" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "logs in with a username and password" do
    post session_path, params: { username: "acme", password: "password123" }

    assert_redirected_to root_url
    follow_redirect!
    follow_redirect!
    assert_select "h1", /Welcome back/
  end

  test "rejects a wrong password" do
    post session_path, params: { username: "acme", password: "nope" }

    assert_redirected_to new_session_path
    assert_equal "Invalid username or password.", flash[:alert]
  end

  test "an expired session no longer signs in" do
    sign_in_as clients(:acme)
    Current.session.update_columns(created_at: 31.days.ago)

    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "logs out" do
    sign_in_as clients(:acme)

    assert_difference -> { Session.count }, -1 do
      delete logout_path
    end
    assert_redirected_to new_session_path
  end
end
