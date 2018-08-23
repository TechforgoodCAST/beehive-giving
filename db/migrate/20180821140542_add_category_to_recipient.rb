class AddCategoryToRecipient < ActiveRecord::Migration[5.1]
  def change
    add_column(:recipients, :category_code, :integer)
    add_column(:recipients, :description, :string)

    add_reference(:recipients, :user, index: true)

    add_reference(:recipients, :district, index: true)
    rename_column(:recipients, :country, :country_alpha2)
    add_reference(:recipients, :country, index: true)

    Recipient.find_each do |r|
      r.update_attribute(:country, Country.find_by(alpha2: r.country_alpha2))
      print '.'
    end
  end
end
