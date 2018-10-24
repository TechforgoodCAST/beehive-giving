# TODO: remove after v3
class UpdateFundCategoryColumns < ActiveRecord::Migration[5.1]
  def up
    new_recipient_categories = {
      -1 => 101,
      0  => [201, 202, 203],
      1  => 301,
      2  => 302,
      3  => [301, 302],
      4  => 102,
      5  => 302
    }

    new_proposal_categories = {
      1 => 201,
      2 => 203,
      3 => 101
    }

    new_geo_scale = {
      0 => 'local',
      1 => 'regional',
      2 => 'national',
      3 => 'international'
    }

    Fund.active.each do |fund|
      updated_recipient_categories = fund.recipient_categories.map do |old|
        new_recipient_categories[old]
      end
      fund.recipient_categories = updated_recipient_categories.flatten.uniq
      fund.proposal_categories.map! { |old| new_proposal_categories[old] }

      fund.proposal_permitted_geographic_scales = [
        'local',
        'regional',
        ('national' if fund.national?),
        ('international' if fund.countries.size > 1)
      ].compact

      fund.save(validate: false)
      print '.'
    end
    puts
  end
end
