class Subscription < ActiveRecord::Base
  PLANS = {
    'Pro - Micro':   5_000,
    'Pro - Small':  10_000,
    'Pro - Medium': 30_000,
    'Pro - Large': 120_000
  }.freeze

  PLANS_B = {
    'Pro - Micro B': 3_600,
    'Pro - Small B': 5_000
  }.freeze

  belongs_to :organisation
end
