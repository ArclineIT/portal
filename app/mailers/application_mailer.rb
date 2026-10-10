class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_FROM", "portal@arclineit.com")
  layout "mailer"
end
