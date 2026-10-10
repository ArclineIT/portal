# Creates the first admin account. Set PORTAL_ADMIN_USERNAME, PORTAL_ADMIN_NAME
# and PORTAL_ADMIN_PASSWORD; outside production they default to a local login.
username = ENV.fetch("PORTAL_ADMIN_USERNAME", "admin")
password = ENV.fetch("PORTAL_ADMIN_PASSWORD") do
  raise "PORTAL_ADMIN_PASSWORD is required in production" if Rails.env.production?
  "password123"
end

Client.find_or_create_by!(username: username) do |client|
  client.display_name = ENV.fetch("PORTAL_ADMIN_NAME", "Admin")
  client.email_address = ENV.fetch("PORTAL_ADMIN_EMAIL", "")
  client.password = password
  client.admin = true
end
