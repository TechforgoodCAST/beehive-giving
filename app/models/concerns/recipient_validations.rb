module RecipientValidations
  extend ActiveSupport::Concern

  included do
    validates :name, :country, :operating_for, :income_band, :employees,
              :volunteers, presence: true

    validates :operating_for, inclusion: { in: OPERATING_FOR.pluck(1) }

    validates :income_band, inclusion: { in: INCOME_BANDS.pluck(1) }

    validates :employees, :volunteers, inclusion: { in: EMPLOYEES.pluck(1) }

    validates :street_address, presence: true, if: :unregistered_org
  end

  private

    def unregistered_org
      [nil, 0, 4].include?(org_type)
    end
end
