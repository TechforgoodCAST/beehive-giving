module RegNoValidations
  extend ActiveSupport::Concern

  included do
    validates :charity_number, presence: {
      if: -> { [1, 3].include? org_type }
    }
    validates :company_number, presence: {
      if: -> { [2, 3, 5].include? org_type }
    }
  end
end
