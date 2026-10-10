class TicketMessage < ApplicationRecord
  belongs_to :ticket

  normalizes :body, with: ->(body) { body.strip }

  validates :body, presence: true
end
