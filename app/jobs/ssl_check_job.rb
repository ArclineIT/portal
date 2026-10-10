class SslCheckJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(domain)
    domain.record_check!(SslCheck.call(domain.name))
  end
end
