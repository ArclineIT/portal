require "test_helper"

class DomainsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as clients(:acme) }

  test "lists only the client's own domains" do
    get domains_path

    assert_response :success
    assert_select "td", text: "acme.test"
    assert_select "td", text: "globex.test", count: 0
  end

  test "adds a domain and queues a certificate check" do
    assert_enqueued_with job: SslCheckJob do
      assert_difference -> { clients(:acme).domains.count } do
        post domains_path, params: { name: "https://new.example.com/" }
      end
    end
    assert_equal "new.example.com", clients(:acme).domains.order(:id).last.name
  end

  test "reports an invalid or duplicate domain" do
    assert_no_difference -> { Domain.count } do
      post domains_path, params: { name: "" }
      post domains_path, params: { name: "acme.test" }
    end
    assert_redirected_to domains_path
    assert flash[:alert].present?
  end

  test "removes a domain" do
    assert_difference -> { Domain.count }, -1 do
      delete domain_path(domains(:acme_ok))
    end
  end

  test "cannot remove another client's domain" do
    assert_no_difference -> { Domain.count } do
      delete domain_path(domains(:globex_site))
    end
    assert_response :not_found
  end
end
