namespace :ssl do
  desc "Check the certificate of every tracked domain (run daily)"
  task check: :environment do
    domains = Domain.all.to_a
    domains.each { |domain| SslCheckJob.perform_now(domain) }
    puts "Checked #{domains.size} domains."
  end
end

namespace :sessions do
  desc "Delete login sessions older than Session::TTL"
  task purge: :environment do
    deleted = Session.expired.delete_all
    puts "Purged #{deleted} expired sessions."
  end
end
