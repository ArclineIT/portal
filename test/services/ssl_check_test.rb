require "test_helper"

class SslCheckTest < ActiveSupport::TestCase
  Certificate = Struct.new(:not_before, :not_after)

  setup { @now = Time.utc(2026, 6, 1) }

  test "a certificate inside its validity window is valid" do
    result = evaluate(Certificate.new(@now - 30.days, @now + 60.days))

    assert result.valid
    assert_equal @now + 60.days, result.expires_at
    assert_equal "", result.error
  end

  test "an expired certificate is invalid" do
    result = evaluate(Certificate.new(@now - 90.days, @now - 1.day))

    assert_not result.valid
    assert_equal "certificate expired 2026-05-31", result.error
  end

  test "a certificate that is not yet valid is invalid" do
    result = evaluate(Certificate.new(@now + 1.day, @now + 90.days))

    assert_not result.valid
    assert_match "not yet valid", result.error
  end

  test "a failed connection is reported, not raised" do
    check = SslCheck.new("unreachable.invalid")
    stub_method(check, :fetch_certificate, -> { raise SocketError, "getaddrinfo: nodename nor servname provided" }) do
      result = check.call

      assert_not result.valid
      assert_nil result.expires_at
      assert_match "tls dial: getaddrinfo", result.error
    end
  end

  private
    def evaluate(certificate)
      SslCheck.new("example.com", now: @now).evaluate(certificate)
    end
end
