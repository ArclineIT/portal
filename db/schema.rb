# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_10_050001) do
  create_table "client_monitors", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "monitor_name", null: false
    t.string "label", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "monitor_name"], name: "index_client_monitors_on_client_id_and_monitor_name", unique: true
    t.index ["client_id"], name: "index_client_monitors_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "username", null: false
    t.string "display_name", null: false
    t.string "email_address", default: "", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_clients_on_email_address"
    t.index ["username"], name: "index_clients_on_username", unique: true
  end

  create_table "domains", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "name", null: false
    t.datetime "last_checked_at"
    t.datetime "expires_at"
    t.boolean "certificate_valid", default: false, null: false
    t.string "check_error", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "name"], name: "index_domains_on_client_id_and_name", unique: true
    t.index ["client_id"], name: "index_domains_on_client_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sessions_on_client_id"
  end

  create_table "ticket_messages", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.text "body", null: false
    t.boolean "from_admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_messages_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "subject", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "updated_at"], name: "index_tickets_on_client_id_and_updated_at"
    t.index ["client_id"], name: "index_tickets_on_client_id"
  end

  add_foreign_key "client_monitors", "clients", on_delete: :cascade
  add_foreign_key "domains", "clients", on_delete: :cascade
  add_foreign_key "sessions", "clients", on_delete: :cascade
  add_foreign_key "ticket_messages", "tickets", on_delete: :cascade
  add_foreign_key "tickets", "clients", on_delete: :cascade
end
