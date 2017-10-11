class GeoArea < ApplicationRecord
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :countries

  has_many :funds

  validates :name, presence: true, uniqueness: true
  validates :countries, presence: true

  # validate :validate_districts

  def short_name
    self[:short_name].present? ? self[:short_name] : self[:name]
  end

  private

    def validate_districts
      return if countries.empty?
      state = [geographic_scale_limited?, national?]
      case state
      when [false, false] # anywhere
        errors.add(:districts, 'must be blank') unless districts.empty?
      when [false, true]  # invalid
        errors.add(:national, 'cannot be set unless geographic scale limited')
      when [true, true]   # national
        errors.add(:districts, 'must be blank for national funds') unless districts.empty?
      when [true, false]  # local
        countries.each do |country|
          errors.add(:districts, "for #{country.name} not selected") if
            (district_ids & country.district_ids).count.zero?
        end
      end
    end
end
