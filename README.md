# Arcline Portal

Customer dashboard for arcline.it. Customers track SSL certificate expiry,
see the status of their monitored services, and open support tickets, without
needing SSH access to anything.

This is the Ruby on Rails rewrite of the original Go service (preserved in the
repository history).

## Features

- **SSL expiry dashboard.** Customers add domains; each certificate is checked
  over TLS when added and then daily. Green is more than 30 days left, amber is
  14 to 30, red is under 14 or invalid.
- **Service status.** Reads arcline-uptime's database (read-only) and shows the
  monitors an admin has linked to each client, with 24 hour, 7 day and 30 day
  uptime.
- **Support tickets.** A customer opens a ticket and the admin is emailed.
  Replies are threaded in the portal, and the customer is emailed when the
  admin replies.
- **Admin area.** Create and delete clients, link uptime monitors, and see
  every ticket.
- Username and password login, password reset by email, rate-limited sign in.

## Requirements

- Ruby 4.0+
- SQLite 3 (bundled via the `sqlite3` gem)
- SMTP credentials for email (password resets and ticket notifications)

## Setup

```bash
bin/setup                 # install gems and prepare the database
cp .env.example .env      # then fill in your values
bin/rails db:seed         # create the first admin account
bin/rails server          # http://localhost:3000, or PORT if set
```

`db:seed` creates an admin from `PORTAL_ADMIN_USERNAME`, `PORTAL_ADMIN_NAME`
and `PORTAL_ADMIN_PASSWORD`. Outside production these default to
`admin` / `password123`. Clients do not register themselves; an admin creates
their accounts under `/admin`.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | HTTP listen port (the original service used `8082`) |
| `DATABASE_PATH` | `storage/<env>.sqlite3` | SQLite database file |
| `UPTIME_DB_PATH` | — | arcline-uptime's SQLite database, opened read-only. Unset hides service status |
| `BASE_URL` | — | Public base URL, used for links in email |
| `SMTP_HOST` | — | SMTP server hostname |
| `SMTP_PORT` | `587` | SMTP port (STARTTLS) |
| `SMTP_USER` | — | SMTP username |
| `SMTP_PASS` | — | SMTP password |
| `SMTP_FROM` | `portal@arcline.it` | From address for outgoing email |
| `ADMIN_EMAIL` | — | Receives new-ticket and client-reply notifications |

## Scheduled tasks

Run these from cron or a systemd timer:

```bash
bin/rails ssl:check        # daily: re-check every tracked certificate
bin/rails sessions:purge   # daily: delete logins older than 30 days
```

## Tests

```bash
bin/rails test
bin/rubocop
bin/brakeman
```

## Deployment

The app ships with a `Dockerfile` and a Kamal config (`config/deploy.yml`).
The SQLite database lives in `storage/`, which is mounted as a volume.

## License

MIT. See [LICENSE](LICENSE).
