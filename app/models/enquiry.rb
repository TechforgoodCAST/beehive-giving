class Enquiry < ActiveRecord::Base

  belongs_to :recipient
  belongs_to :funder
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  validates :funder, :recipient, presence: true
  validates :new_project, presence: true, if: :new_project?
  validates :new_location, presence: true, if: :new_location?
  validates :amount_seeking, :duration_seeking, presence: true
  validates :countries, :districts, presence: true,
            unless: Proc.new { |enquiry| enquiry.new_location == false }
  validates :new_project, :new_location, :inclusion => { in: [true, false] }
  validates :amount_seeking, :duration_seeking,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates_uniqueness_of :recipient, scope: :funder_id, :message => 'only one match per funder'

end
