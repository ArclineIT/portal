require "openssl"
require "socket"

# Connects to a host on port 443 and reads the expiry of its leaf certificate.
class SslCheck
  TIMEOUT = 10

  Result = Data.define(:domain, :expires_at, :valid, :error)

  def self.call(domain, now: Time.current)
    new(domain, now: now).call
  end

  def initialize(domain, now: Time.current)
    @domain = domain
    @now = now
  end

  def call
    certificate = fetch_certificate
    return failure("no certificates in chain") if certificate.nil?

    evaluate(certificate)
  rescue OpenSSL::SSL::SSLError, SystemCallError, SocketError, IO::TimeoutError, Timeout::Error => e
    failure("tls dial: #{e.message}")
  end

  # Split out so a certificate can be judged without a network connection.
  def evaluate(certificate)
    expires_at = certificate.not_after

    if @now < certificate.not_before
      result(expires_at, false, "certificate not yet valid (valid from #{certificate.not_before.to_date.iso8601})")
    elsif @now > expires_at
      result(expires_at, false, "certificate expired #{expires_at.to_date.iso8601}")
    else
      result(expires_at, true, "")
    end
  end

  private
    def fetch_certificate
      tcp = TCPSocket.new(@domain, 443, connect_timeout: TIMEOUT)
      context = OpenSSL::SSL::SSLContext.new
      context.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)

      ssl = OpenSSL::SSL::SSLSocket.new(tcp, context)
      ssl.hostname = @domain
      ssl.sync_close = true
      Timeout.timeout(TIMEOUT) { ssl.connect }
      ssl.post_connection_check(@domain)
      ssl.peer_cert
    ensure
      ssl ? ssl.close : tcp&.close
    end

    def failure(message)
      result(nil, false, message)
    end

    def result(expires_at, valid, error)
      Result.new(domain: @domain, expires_at: expires_at, valid: valid, error: error)
    end
end
