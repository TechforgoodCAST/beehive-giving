module Signup
  class Basics
    extend SetterToInteger

    include ActiveModel::Model
    include OrgTypeValidations
    include RegNoValidations

    attr_accessor :charity_number, :company_number, :country, :funding_type,
                  :org_type, :themes

    validates :country, :themes, presence: true
    validates :funding_type, inclusion: {
      in: FUNDING_TYPES.pluck(1),
      message: 'please select a valid option'
    }

    validate :validate_themes

    to_integer :org_type, :funding_type

    def proposal
      %i[
        funding_type themes
      ].map { |a| [a, send(a)] }.to_h
    end

    def recipient
      %i[
        charity_number company_number country org_type
      ].map { |a| [a, send(a)] }.to_h
    end

    def attributes
      proposal.merge(recipient)
    end

    private

      def validate_themes
        errors.add(:themes, "can't be blank") if themes&.all?(&:blank?)
      end
  end
end