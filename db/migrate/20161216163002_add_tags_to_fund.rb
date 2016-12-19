class AddTagsToFund < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :tags, :jsonb, null: false, default: []
    add_index  :funds, :tags, using: :gin

    Fund.find_each do |f|
      tag_ids = ActsAsTaggableOn::Tagging.where(taggable_id: f.id, taggable_type: 'Fund').pluck(:tag_id)
      old_tags = ActsAsTaggableOn::Tag.find(tag_ids).pluck(:name)
      if f.update(tags: old_tags)
        print '.'
      end
    end
  end
end
