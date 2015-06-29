class Feedback < ActiveRecord::Base
  belongs_to :user

  NPS = ['- Not likely at all', '', '', '', '', '- Neutral', '', '', '', '', '- Extremely likely']
  TAKEN_AWAY = ['- Very satisfied', '', '', '', '', '- Neutral', '', '', '', '', '- Very dissatisfied']
  INFORMS_DECISION = ['- Strongly disagree', '', '', '', '', '- Neutral', '', '', '', '', '- Strongly agree']

  validates :user, :nps, :taken_away, :informs_decision, presence: true
  validates :nps, :taken_away, :informs_decision, inclusion: {in: 1..10}
end
