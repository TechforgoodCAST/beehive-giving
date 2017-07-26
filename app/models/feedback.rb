class Feedback < ApplicationRecord
  SUITABLE = ['- Very unsuitable'] +
             Array.new(9, '') +
             ['- Very suitable'].freeze
  MOST_USEFUL = ['The information about funders',
                 'Recommendations of funders',
                 'Being able to check your eligibility',
                 'Other'].freeze
  NPS = ['- Not at all likely'] +
        Array.new(9, '') +
        ['- Extremely likely'].freeze
  TAKEN_AWAY = ['- Very satisfied'] +
               Array.new(9, '') +
               ['- Very dissatisfied'].freeze
  INFORMS_DECISION = ['- Strongly disagree'] +
                     Array.new(9, '') +
                     ['- Strongly agree'].freeze
  APP_AND_GRANT_FREQUENCY = ['None', '1-3', '4-6', '7-9', '10 or more'].freeze
  MARKETING_FREQUENCY = %w(Weekly Monthly Quartetly Never).freeze

  belongs_to :user

  validates :user, :suitable, :most_useful, :nps, :taken_away,
            :informs_decision, :application_frequency, :grant_frequency,
            :marketing_frequency, presence: true
  validates :most_useful, inclusion: { in: MOST_USEFUL }
  validates :suitable, :nps, :taken_away, :informs_decision,
            inclusion: { in: 1..10 }
  validates :application_frequency, inclusion: { in: APP_AND_GRANT_FREQUENCY }
  validates :grant_frequency, inclusion: { in: APP_AND_GRANT_FREQUENCY }
  validates :marketing_frequency, inclusion: { in: MARKETING_FREQUENCY }
  validates :price, presence: true, on: :update
  validates :price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            on: :update
end
