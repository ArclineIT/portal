# Links a client to a monitor name in arcline-uptime.
class ClientMonitor < ApplicationRecord
  belongs_to :client

  normalizes :monitor_name, :label, with: ->(value) { value.to_s.strip }

  validates :monitor_name, presence: true, uniqueness: { scope: :client_id }

  scope :ordered, -> { order(:label, :monitor_name) }

  def display_name
    label.presence || monitor_name
  end
end
