class AddCategoryToRecipient < ActiveRecord::Migration[5.1]
  def change
    add_column(:recipients, :category_code, :integer)
    add_column(:recipients, :description, :string)

    add_reference(:recipients, :user, index: true)

    add_reference(:recipients, :district, index: true)
    rename_column(:recipients, :country, :country_alpha2)
    add_reference(:recipients, :country, index: true)

    reversible do |dir|
      dir.up do
        new_recipient_categories = {
          -1 => 101,
          0  => 202,
          1  => 301,
          2  => 302,
          3  => 301,
          4  => 102,
          5  => 302
        }

        Recipient.find_each do |r|
          country = Country.find_by(alpha2: r.country_alpha2)
          next if country.nil?

          r.update_columns(
            country_id: country.id,
            category_code: new_recipient_categories[r.org_type]
          )
          print '.'
        end
      end
    end
  end
end
