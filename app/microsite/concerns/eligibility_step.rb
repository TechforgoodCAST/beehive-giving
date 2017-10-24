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
    @answers ||= []
  end

  def answers=(answers)
    @answers = answers.map { |_criterion_id, answer| Answer.new(answer) }
  end

  validate :validate_answers

  def attributes
    self.class.attrs.map { |a| [a, send(a)] }.to_h
  end

  def build_answers(funder, category)
    funder.restrictions
          .select { |criterion| criterion.category == category.class.name }
          .map do |criterion|
            Answer.new(category: category, criterion: criterion)
          end
  end

  def answers_for(category)
    answers.select { |a| a.category_type == category }
  end

  def save
    if valid?
      save_recipient!
      # TODO: run eligibility checks
      # TODO: update proposal
      # TODO: update assessment state
    else
      false
    end
  end

  private

    def validate_answers
      answers.each do |answer|
        answer.valid? ? next : errors.add('answer', 'invalid')
      end
    end

    def save_recipient!
      assessment.recipient.update(attributes.except(:assessment))
    end
end
