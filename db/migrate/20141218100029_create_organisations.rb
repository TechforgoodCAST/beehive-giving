class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :organisation
      t.string :first_name, :last_name, :job_role, :user_email, required: true
      t.string :password_digest, :auth_token, :password_reset_token
      t.string :role, default: 'User'
      t.datetime :password_reset_sent_at

      t.timestamps null: false
    end

    create_table :organisations do |t|
      t.string :name, required: true
      t.string :contact_number, :website, :street_address, :city, :region, :postal_code, :country, :charity_number, :company_number, :slug, :type
      t.date :founded_on, :registered_on

      t.timestamps null: false
    end

    add_index :organisations, :slug, unique: true
  end
end
