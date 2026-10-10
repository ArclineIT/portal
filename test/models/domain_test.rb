require "test_helper"

class DomainTest < ActiveSupport::TestCase
  test "strips the scheme and trailing slash from a pasted URL" do
    domain = clients(:acme).domains.create!(name: " HTTPS://Example.com/ ")
    assert_equal "example.com", domain.name
  end

  test "rejects names that are not hostnames" do
    assert_not clients(:acme).domains.new(name: "example.com/path?x=1").valid?
    assert_not clients(:acme).domains.new(name: "").valid?
  end

  test "a domain is unique per client" do
    assert_not clients(:acme).domains.new(name: "acme.test").valid?
    assert clients(:globex).domains.new(name: "acme.test").valid?
  end

  test "severity follows the days remaining" do
    domain = Domain.new(last_checked_at: Time.current, certificate_valid: true)

    domain.expires_at = 45.days.from_now
    assert_equal "ok", domain.severity

    domain.expires_at = 20.days.from_now
    assert_equal "warn", domain.severity

    domain.expires_at = 5.days.from_now
    assert_equal "crit", domain.severity
  end

  test "an invalid certificate is critical and an unchecked domain is pending" do
    assert_equal "crit", Domain.new(last_checked_at: Time.current, expires_at: 90.days.from_now).severity
    assert_equal "pending", Domain.new.severity
  end

  test "record_check! stores the result" do
    domain = domains(:globex_site)
    domain.record_check!(SslCheck::Result.new(domain: domain.name, expires_at: nil, valid: false, error: "tls dial: refused"))

    assert domain.checked?
    assert_not domain.certificate_valid?
    assert_equal "tls dial: refused", domain.check_error
  end
end
