class GeoArea < ApplicationRecord
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :countries

  has_many :funds

  validates :name, presence: true, uniqueness: true
  validates :countries, presence: true

  validate :validate_districts

  def short_name
    self[:short_name].present? ? self[:short_name] : self[:name]
  end

  private

    def validate_districts
      return if districts.empty?

      districts.each do |district|
        msg = "Country '#{district.country.name}' " \
              "for #{district.name} not selected"

        errors.add(:districts, msg) if country_ids.exclude?(district.country_id)
      end
    end
end
