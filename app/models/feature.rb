class Feature < ActiveRecord::Base
  belongs_to :funder
  belongs_to :recipient

  validates_uniqueness_of :funder_id, scope: :recipient_id, if: :data_requested?
  validates_uniqueness_of :request_amount_awarded, scope: [:funder_id, :recipient_id], if: :request_amount_awarded?
  validates_uniqueness_of :request_funding_dates, scope: [:funder_id, :recipient_id], if: :request_funding_dates?
  validates_uniqueness_of :request_funding_countries, scope: [:funder_id, :recipient_id], if: :request_funding_countries?
  validates_uniqueness_of :request_grant_count, scope: [:funder_id, :recipient_id], if: :request_grant_count?
  validates_uniqueness_of :request_applications_count, scope: [:funder_id, :recipient_id], if: :request_applications_count?
  validates_uniqueness_of :request_enquiry_count, scope: [:funder_id, :recipient_id], if: :request_enquiry_count?
  validates_uniqueness_of :request_funding_types, scope: [:funder_id, :recipient_id], if: :request_funding_types?
  validates_uniqueness_of :request_funding_streams, scope: [:funder_id, :recipient_id], if: :request_funding_streams?
  validates_uniqueness_of :request_approval_months, scope: [:funder_id, :recipient_id], if: :request_approval_months?
end
