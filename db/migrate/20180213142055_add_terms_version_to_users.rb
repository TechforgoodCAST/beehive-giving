class AddTermsVersionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :terms_version, :date
  end
end
