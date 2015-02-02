class Feature < ActiveRecord::Base
  belongs_to :funder
  belongs_to :recipient

  validates_uniqueness_of :funder_id, scope: :recipient_id, if: :data_requested?
end
