# A customer-owned domain tracked for SSL certificate expiry.
class Domain < ApplicationRecord
  belongs_to :client

  normalizes :name, with: ->(name) { name.strip.downcase.delete_prefix("https://").delete_prefix("http://").delete_suffix("/") }

  validates :name, presence: true, uniqueness: { scope: :client_id },
                   format: { with: /\A[a-z0-9]([a-z0-9.-]*[a-z0-9])?\z/, message: "is not a valid hostname" }

  scope :by_name, -> { order(:name) }

  def checked?
    last_checked_at.present?
  end

  def days_remaining
    return 0 if expires_at.blank?
    ((expires_at - Time.current) / 1.day).floor
  end

  # "ok" over 30 days, "warn" for 14 to 30, "crit" under 14 or invalid.
  def severity
    return "pending" unless checked?
    return "crit" unless certificate_valid?

    if days_remaining > 30 then "ok"
    elsif days_remaining >= 14 then "warn"
    else "crit"
    end
  end

  def record_check!(result)
    update!(last_checked_at: Time.current, expires_at: result.expires_at,
            certificate_valid: result.valid, check_error: result.error.to_s)
  end
end
