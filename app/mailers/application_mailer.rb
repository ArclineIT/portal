class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_FROM", "portal@arcline.it")
  layout "mailer"
end
