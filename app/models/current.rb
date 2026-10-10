class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :client, to: :session, allow_nil: true
end
