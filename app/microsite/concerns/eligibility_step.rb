class EligibilityStep
  extend SetterToInteger
  include ActiveModel::Model
  include RecipientValidations
  include RegNoValidations
  include OrgTypeValidations

  def self.attrs
    %i[attempt org_type charity_number company_number name country
       street_address income_band operating_for employees volunteers
       affect_geo country_ids district_ids]
  end

  attr_accessor(*attrs)

  def answers
    @answers ||= build_answers
  end

  def answers=(answers)
    @answers = build_answers(answers)
  end

  def country_ids
    @country_ids ||= []
  end

  def district_ids
    @district_ids ||= []
  end

  to_integer :org_type, :income_band, :operating_for, :employees, :volunteers,
             :affect_geo

  validates :affect_geo, inclusion: { in: 0..3,
                                      message: 'please select an option' }
  validate :country_ids_presence, :district_ids_presence, :validate_answers

  def attributes
    self.class.attrs.map { |a| [a, send(a)] }.to_h.merge(answers: answers)
  end

  def answers_for(category)
    answers.select { |a| a.category_type == category }
  end

  def save
    if valid?
      save_attempt! if save_recipient! && save_proposal!
    else
      false
    end
  end

  private

    def funder
      attempt&.funder
    end

    def proposal
      attempt&.proposal
    end

    def recipient
      attempt&.recipient
    end

    def build_answers(updates = {})
      return [] unless attempt

      criteria = funder.restrictions.uniq
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

    def validate_array(field)
      errors.add(field, "can't be blank") if send(field).reject(&:blank?).empty?
    end

    def country_ids_presence
      return if affect_geo && affect_geo < 3
      validate_array(:country_ids)
    end

    def district_ids_presence
      return if affect_geo && affect_geo > 1
      validate_array(:district_ids)
    end

    def save_recipient!
      recipient.update(
        attributes.except(
          :attempt, :answers, :affect_geo, :country_ids, :district_ids
        )
      )
    end

    def save_proposal!
      proposal.assign_attributes(
        affect_geo: affect_geo,
        country_ids: (country_ids << Country.find_by(alpha2: country).id).uniq,
        district_ids: district_ids
      )
      Proposal.skip_callback :save, :after, :initial_recommendation # TODO: refactor
      proposal.save(validate: false)
      Proposal.set_callback :save, :after, :initial_recommendation # TODO: refactor
      funds = funder.funds.active
      eligibility = CheckEligibilityFactory.new(proposal, funds)
                                           .call_each(proposal, funds)
      proposal.next_step!
      proposal.update_column(:eligibility, eligibility)
    end

    def save_attempt!
      attempt.update(state: 'pre_results')
    end
end
