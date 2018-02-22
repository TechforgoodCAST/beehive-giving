class AddRevealedToAssessments < ActiveRecord::Migration[5.1]
  def up
    add_column :assessments, :revealed, :boolean

    Recipient.where("reveals != '[]'::jsonb").find_each do |r|
      Assessment.where(recipient: r, fund: Fund.where(slug: r.reveals))
                .update_all(revealed: true)
    end
  end

  def down
    remove_column :assessments, :revealed
  end
end
