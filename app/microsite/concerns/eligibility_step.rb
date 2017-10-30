class EligibilityStep
  extend SetterToInteger
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

  to_integer :org_type, :income_band, :operating_for, :employees, :volunteers

  validate :validate_answers

  def attributes
    self.class.attrs.map { |a| [a, send(a)] }.to_h.merge(answers: answers)
  end

  def answers_for(category)
    answers.select { |a| a.category_type == category }
  end

  def save
    if valid?
      save_assessment! if save_recipient! && save_proposal!
    else
      false
    end
  end

  private

    def funder
      assessment&.funder
    end

    def proposal
      assessment&.proposal
    end

    def recipient
      assessment&.recipient
    end

    def build_answers(updates = {})
      return [] unless assessment

      criteria = funder.restrictions
      answers = persisted_answers(criteria)

      criteria.map do |criterion|
        answer = answers[criterion.id] || new_answer(criterion)
        update_answer(updates, criterion, answer)
        answer
      end
    end

    def update_answer(updates, criterion, answer)
      update = updates.dig(criterion.id.to_s, 'eligible')
      answer.eligible = update.nil? ? answer.eligible : update
    end

    def persisted_answers(criteria)
      Answer.includes(:criterion).where(
        category: [recipient, proposal],
        criterion: criteria.pluck(:id)
      ).map { |a| [a.criterion_id, a] }.to_h
    end

    def new_answer(criterion)
      Answer.new(
        category: lookup_category(criterion.category),
        criterion: criterion
      )
    end

    def lookup_category(category_type)
      category_type == 'Recipient' ? recipient : proposal
    end

    def validate_answers
      answers.each do |answer|
        answer.valid? ? answer.save : errors.add('answer', 'invalid')
      end
    end

    def save_recipient!
      recipient.update(attributes.except(:assessment, :answers))
    end

    def save_proposal!
      eligibility = CheckEligibilityFactory.new(proposal, funder.funds)
                                           .call_each(proposal, funder.funds)
      proposal.update_column(:eligibility, eligibility)
    end

    def save_assessment!
      assessment.update(state: 'results')
    end
end
