class Ticket < ApplicationRecord
  STATUSES = %w[ open in_progress closed ].freeze

  belongs_to :client
  has_many :messages, -> { order(:created_at, :id) }, class_name: "TicketMessage", dependent: :destroy

  normalizes :subject, with: ->(subject) { subject.strip }

  validates :subject, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(updated_at: :desc) }

  # Opens a ticket together with its first message.
  def self.open_for(client, subject:, body:)
    transaction do
      client.tickets.create!(subject: subject).tap do |ticket|
        ticket.messages.create!(body: body)
      end
    end
  end

  def closed?
    status == "closed"
  end

  def reply!(body, from_admin:, close: false)
    transaction do
      message = messages.create!(body: body, from_admin: from_admin)
      update!(status: close ? "closed" : status, updated_at: Time.current)
      message
    end
  end
end
