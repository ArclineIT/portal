class CreatePortalTables < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :username, null: false
      t.string :display_name, null: false
      t.string :email_address, null: false, default: ""
      t.string :password_digest, null: false
      t.boolean :admin, null: false, default: false
      t.timestamps
    end
    add_index :clients, :username, unique: true
    add_index :clients, :email_address

    create_table :sessions do |t|
      t.references :client, null: false, foreign_key: { on_delete: :cascade }
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    create_table :domains do |t|
      t.references :client, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.datetime :last_checked_at
      t.datetime :expires_at
      t.boolean :certificate_valid, null: false, default: false
      t.string :check_error, null: false, default: ""
      t.timestamps
    end
    add_index :domains, [ :client_id, :name ], unique: true

    create_table :client_monitors do |t|
      t.references :client, null: false, foreign_key: { on_delete: :cascade }
      t.string :monitor_name, null: false
      t.string :label, null: false, default: ""
      t.timestamps
    end
    add_index :client_monitors, [ :client_id, :monitor_name ], unique: true

    create_table :tickets do |t|
      t.references :client, null: false, foreign_key: { on_delete: :cascade }
      t.string :subject, null: false
      t.string :status, null: false, default: "open"
      t.timestamps
    end
    add_index :tickets, [ :client_id, :updated_at ]

    create_table :ticket_messages do |t|
      t.references :ticket, null: false, foreign_key: { on_delete: :cascade }
      t.text :body, null: false
      t.boolean :from_admin, null: false, default: false
      t.timestamps
    end
  end
end
