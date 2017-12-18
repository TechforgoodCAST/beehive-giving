module OrgTypeValidations
  extend ActiveSupport::Concern

  included do
    validates :org_type, inclusion: {
      in: (ORG_TYPES.pluck(1) - [-1]),
      message: 'please select a valid option'
    }
  end
end
