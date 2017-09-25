class TransferOrganisationsToFunders < ActiveRecord::Migration[5.1]
  def up
    Recipient.where(type_temp: 'Funder').each do |funder|
      w = URI.parse(funder.website)
      funder.website = "http://#{funder.website}/" unless w.scheme
      Funder.create!(
        id: funder.id,
        slug: funder.slug,
        name: funder.name,
        website: funder.website,
        charity_number: funder.charity_number,
        company_number: funder.company_number,
        active: funder.active_on_beehive
      )
      funder.destroy
    end
    remove_column :recipients, :type_temp
    User.where(organisation_type: 'User').update_all(organisation_type: 'Recipient')
    Restriction.where(category: 'Organisation').update_all(category: 'Recipient')
    if defined? Eligibility
      Eligibility.where(category_type: 'Organisation').update_all(category_type: 'Recipient')
    end
    if defined? Answer
      Answer.where(category_type: 'Organisation').update_all(category_type: 'Recipient')
    end
  end
end
