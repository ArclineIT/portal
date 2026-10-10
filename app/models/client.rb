class Client < ApplicationRecord
  MIN_PASSWORD_LENGTH = 8

  has_secure_password reset_token: { expires_in: 1.hour }
  has_many :sessions, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :monitors, class_name: "ClientMonitor", dependent: :destroy
  has_many :tickets, dependent: :destroy

  normalizes :username, with: ->(u) { u.strip }
  normalizes :display_name, with: ->(n) { n.strip }
  normalizes :email_address, with: ->(e) { e.to_s.strip.downcase }

  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_nil: true

  scope :by_name, -> { order(:display_name) }

  # Clients created without an email cannot be matched by a blank address.
  def self.find_by_email(email)
    email = email.to_s.strip.downcase
    find_by(email_address: email) if email.present?
  end
end
