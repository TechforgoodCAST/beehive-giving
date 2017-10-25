class EligibilityStep
  include ActiveModel::Model
  include RecipientValidations
  include RegNoValidations
  include OrgTypeValidations

  def self.attrs
    %i[assessment org_type charity_number company_number name country
       street_address income_band operating_for employees volunteers]
  end

  attr_accessor(*attrs)

  def answers
    @answers ||= build_answers
  end

  def answers=(answers)
    @answers = build_answers(answers)
  end

  validate :validate_answers

  def attributes
    self.class.attrs.map { |a| [a, send(a)] }.to_h
  end

  def answers_for(category)
    answers.select { |a| a.category_type == category }
  end

  def save
    if valid?
      save_recipient! && save_proposal!
      # TODO: update assessment state
    else
      false
    end
  end

  private

    def build_answers(updates = {})
      return [] unless assessment
      assessment.funder.restrictions.map do |criterion|
        answer = load_answer(criterion)
        if answer.eligible.nil?
          answer.eligible = updates.dig(criterion.id.to_s, 'eligible')
        end
        answer
      end
    end

    def load_answer(criterion)
      Answer.where(
        category: lookup_category(criterion.category),
        criterion: criterion
      ).first_or_initialize
    end

    def lookup_category(category_type)
      category_type == 'Recipient' ? assessment.recipient : assessment.proposal
    end

    def validate_answers
      answers.each do |answer|
        answer.valid? ? answer.save : errors.add('answer', 'invalid')
      end
    end

    def save_recipient!
      assessment.recipient.update(attributes.except(:assessment))
    end

    def save_proposal!
      # TODO: refactor with factory
      check_eligibility = Check::Each.new(
        [
          Check::Eligibility::Amount.new,
          Check::Eligibility::Location.new,
          Check::Eligibility::OrgIncome.new,
          Check::Eligibility::OrgType.new,
          Check::Eligibility::Quiz.new(assessment.proposal, assessment.funder.funds)
        ]
      )
      assessment.proposal.update_columns(
        eligibility: check_eligibility.call_each(assessment.proposal, assessment.funder.funds)
      )
    end
end
