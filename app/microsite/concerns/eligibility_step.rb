class EligibilityStep
  include ActiveModel::Model

  attr_accessor :charity_number, :company_number, :name, :country,
                :street_address, :org_type, :income_band, :operating_for,
                :employees, :volunteers, :answers

  # TODO: validations
  validate :validate_answers

  def answers=(answers)
    @answers = answers.map { |_criterion_id, answer| Answer.new(answer) }
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
      # TODO: update recipient
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
end
