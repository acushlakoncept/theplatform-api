class CreateUsers < ActiveRecord::Migration[6.1]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  def change
    create_table :users, id: :uuid do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.string :referral_url, null: false
      t.string :pronouns
      t.string :bio, default: ''
      t.string :skills, array: true, default: []
      t.string :language, array: true, default: []
      t.integer :role, default: 0, null: false
      t.boolean :email_confirmed, default: false, null: false
      t.string :confirm_token
      t.string :phone, null: false, default: ''
      t.string :photo, null: false, default: ''

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :users, :referral_url, unique: true
  end
end
