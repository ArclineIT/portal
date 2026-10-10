require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  test "clients are kept out of the admin area" do
    sign_in_as clients(:acme)

    get admin_root_path
    assert_response :forbidden

    assert_no_difference -> { Client.count } do
      post admin_clients_path, params: { username: "x", display_name: "X", password: "password123" }
      delete admin_client_path(clients(:globex))
    end
    assert_response :forbidden
  end

  test "an admin sees every client and ticket" do
    sign_in_as clients(:admin)

    get admin_root_path
    assert_response :success
    assert_select "td", text: "Acme Co"
    assert_select "td", text: "DNS question"

    get admin_client_path(clients(:acme))
    assert_response :success
    assert_select "td", text: "Main Website"
  end

  test "an admin creates a client" do
    sign_in_as clients(:admin)

    assert_difference -> { Client.count } do
      post admin_clients_path, params: { username: "initech", display_name: "Initech", email_address: "it@initech.test", password: "password123", admin: "0" }
    end
    assert_not Client.find_by!(username: "initech").admin?
  end

  test "a client needs a unique username and a long enough password" do
    sign_in_as clients(:admin)

    assert_no_difference -> { Client.count } do
      post admin_clients_path, params: { username: "acme", display_name: "Dup", password: "password123" }
      post admin_clients_path, params: { username: "fresh", display_name: "Fresh", password: "short" }
    end
    assert flash[:alert].present?
  end

  test "an admin links and unlinks uptime monitors" do
    sign_in_as clients(:admin)
    client = clients(:globex)

    assert_difference -> { client.monitors.count } do
      post admin_client_monitors_path(client), params: { monitor_name: "SSH", label: "" }
    end
    assert_difference -> { client.monitors.count }, -1 do
      delete admin_client_monitor_path(client, client.monitors.last)
    end
  end

  test "an admin deletes a client but not themselves" do
    sign_in_as clients(:admin)

    assert_difference -> { Client.count }, -1 do
      delete admin_client_path(clients(:globex))
    end
    assert_no_difference -> { Client.count } do
      delete admin_client_path(clients(:admin))
    end
  end
end
