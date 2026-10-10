require "test_helper"

class UptimeReaderTest < ActiveSupport::TestCase
  setup do
    @path = Rails.root.join("tmp", "uptime-test-#{SecureRandom.hex(4)}.sqlite3").to_s
    db = SQLite3::Database.new(@path)
    db.execute "CREATE TABLE monitors (id INTEGER PRIMARY KEY, name TEXT NOT NULL)"
    db.execute "CREATE TABLE checks (id INTEGER PRIMARY KEY, monitor_id INTEGER, up INTEGER, response_ms INTEGER, checked_at DATETIME)"
    db.execute "INSERT INTO monitors (id, name) VALUES (1, 'Main Website')"
    [ [ 3.hours.ago, 1, 120 ], [ 2.hours.ago, 0, 0 ], [ 1.hour.ago, 1, 140 ], [ 10.minutes.ago, 1, 95 ] ].each do |at, up, ms|
      db.execute "INSERT INTO checks (monitor_id, up, response_ms, checked_at) VALUES (1, ?, ?, ?)",
                 [ up, ms, at.utc.strftime("%Y-%m-%d %H:%M:%S.%6N") ]
    end
    db.close
  end

  teardown { File.delete(@path) if File.exist?(@path) }

  test "reports the latest check and uptime percentages" do
    status = UptimeReader.new(@path).statuses_for([ client_monitors(:acme_web) ]).first

    assert_equal "Website", status.label
    assert status.up
    assert_equal 95, status.response_ms
    assert_in_delta 10.minutes.ago, status.last_checked, 5.seconds
    assert_in_delta 75.0, status.uptime_24h
    assert_in_delta 75.0, status.uptime_30d
  end

  test "a monitor with no checks is shown as down with full uptime" do
    unknown = ClientMonitor.new(monitor_name: "Nope")
    status = UptimeReader.new(@path).statuses_for([ unknown ]).first

    assert_not status.up
    assert_nil status.last_checked
    assert_equal 100.0, status.uptime_24h
  end

  test "statuses_for is empty when the uptime database is not configured or missing" do
    monitors = [ client_monitors(:acme_web) ]

    stub_method(UptimeReader, :path, -> { nil }) { assert_empty UptimeReader.statuses_for(monitors) }
    stub_method(UptimeReader, :path, -> { "/nonexistent/uptime.sqlite3" }) { assert_empty UptimeReader.statuses_for(monitors) }
    stub_method(UptimeReader, :path, -> { @path }) { assert_equal 1, UptimeReader.statuses_for(monitors).size }
  end
end
