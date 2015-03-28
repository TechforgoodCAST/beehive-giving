class Feature < ActiveRecord::Base
  belongs_to :funder
  belongs_to :recipient

  validates_uniqueness_of :funder_id, scope: :recipient_id, if: :data_requested?
  validates_uniqueness_of :request_amount_awarded, scope: :recipient_id, if: :request_amount_awarded?
  validates_uniqueness_of :request_funding_dates, scope: :recipient_id, if: :request_funding_dates?
  validates_uniqueness_of :request_funding_countries, scope: :recipient_id, if: :request_funding_countries?
end
