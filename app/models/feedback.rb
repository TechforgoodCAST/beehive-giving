class Feedback < ActiveRecord::Base
  belongs_to :user

  NPS = ['- Not likely at all', '', '', '', '', '- Neutral', '', '', '', '', '- Extremely likely']
  TAKEN_AWAY = ['- Very dissatisfied', '', '', '', '', '- Neutral', '', '', '', '', '- Very satisfied']
  INFORMS_DECISION = ['- Strongly disagree', '', '', '', '', '- Neutral', '', '', '', '', '- Strongly agree']

  validates :nps, :taken_away, :informs_decision, presence: true
  validates :nps, :taken_away, :informs_decision, inclusion: {in: 1..10}
end
