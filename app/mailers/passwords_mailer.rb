class PasswordsMailer < ApplicationMailer
  def reset(client)
    @client = client
    mail subject: "Reset your Arcline Portal password", to: client.email_address
  end
end
