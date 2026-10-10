class DomainsController < ApplicationController
  def index
    @domains = Current.client.domains.by_name
  end

  def create
    domain = Current.client.domains.new(name: params[:name].to_s)

    if domain.save
      SslCheckJob.perform_later(domain)
      redirect_to domains_path, notice: "#{domain.name} added. Its certificate is being checked."
    else
      redirect_to domains_path, alert: domain.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.client.domains.find(params[:id]).destroy
    redirect_to domains_path, status: :see_other
  end
end
