require "sqlite3"

# Read-only view of the arcline-uptime database. The portal never writes to it.
class UptimeReader
  Status = Data.define(:name, :label, :up, :last_checked, :response_ms, :uptime_24h, :uptime_7d, :uptime_30d)

  def self.path
    ENV["UPTIME_DB_PATH"].presence
  end

  # Statuses for the given portal monitors, or an empty list when the uptime
  # database is missing or unreadable.
  def self.statuses_for(monitors)
    return [] if monitors.empty? || path.nil? || !File.exist?(path)

    new(path).statuses_for(monitors)
  rescue SQLite3::Exception => e
    Rails.logger.warn("uptime db unavailable: #{e.message}")
    []
  end

  def initialize(path)
    @path = path
  end

  def statuses_for(monitors)
    with_database do |db|
      monitors.map do |monitor|
        latest = db.get_first_row(<<~SQL, [ monitor.monitor_name ])
          SELECT checks.checked_at, checks.up, checks.response_ms FROM checks
          JOIN monitors ON monitors.id = checks.monitor_id
          WHERE monitors.name = ? ORDER BY checks.checked_at DESC LIMIT 1
        SQL

        Status.new(
          name: monitor.monitor_name,
          label: monitor.display_name,
          up: latest ? latest[1].to_i == 1 : false,
          last_checked: latest && Time.zone.parse("#{latest[0]} UTC"),
          response_ms: latest ? latest[2].to_i : 0,
          uptime_24h: uptime_percent(db, monitor.monitor_name, 24.hours.ago),
          uptime_7d: uptime_percent(db, monitor.monitor_name, 7.days.ago),
          uptime_30d: uptime_percent(db, monitor.monitor_name, 30.days.ago)
        )
      end
    end
  end

  private
    def with_database
      db = SQLite3::Database.new(@path, readonly: true)
      yield db
    ensure
      db&.close
    end

    def uptime_percent(db, name, since)
      total, up = db.get_first_row(<<~SQL, [ name, since.utc.strftime("%Y-%m-%d %H:%M:%S") ])
        SELECT COUNT(*), COALESCE(SUM(checks.up), 0) FROM checks
        JOIN monitors ON monitors.id = checks.monitor_id
        WHERE monitors.name = ? AND checks.checked_at >= ?
      SQL
      total.to_i.zero? ? 100.0 : up.to_f / total * 100
    end
end
