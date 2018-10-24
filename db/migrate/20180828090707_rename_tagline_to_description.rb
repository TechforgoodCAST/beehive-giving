class RenameTaglineToDescription < ActiveRecord::Migration[5.1]
  def change
    rename_column(:proposals, :tagline, :description)
    rename_column(:proposals, :funding_type, :category_code)
    add_column(:proposals, :support_details, :string)

    rename_column(:proposals, :total_costs, :min_amount)
    add_column(:proposals, :max_amount, :integer)

    rename_column(:proposals, :funding_duration, :min_duration)
    add_column(:proposals, :max_duration, :integer)

    add_column(:proposals, :geographic_scale, :string)

    reversible do |dir|
      dir.up do
        change_column(:proposals, :min_amount, :integer)

        Proposal.update_all('max_amount = min_amount')
        Proposal.update_all('max_duration = min_duration')

        Proposal.find_each do |proposal|
          support_types = {
            nil => 101, # nil -> Other
            0   => 101, # Don't know -> Other
            1   => 201, # Capital -> Capital
            2   => 203, # Revenue -> Revenue - Project
            3   => 101  # Other -> Other
          }

          geographic_scales = {
            nil => :missing,
            0   => :local,
            1   => :regional,
            2   => :national,
            3   => :international
          }

          old_code = proposal.category_code
          new_code = support_types[old_code]

          proposal.update_columns(
            category_code: new_code,
            support_details: ('No description given' if new_code == 101),
            geographic_scale: geographic_scales[proposal.affect_geo],
            public_consent: proposal.private?
          )

          print '.'
        end
      end
      dir.down do
        change_column(:proposals, :min_amount, :float)
      end
    end
  end
end
