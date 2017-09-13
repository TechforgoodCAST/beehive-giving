class Subscription < ApplicationRecord
  belongs_to :organisation

  def self.plans
    plans = ENV['STRIPE_PLANS']
    raise 'STRIPE_PLANS environment variable not set' unless plans
    raise 'Must have format <name>:<amount>' unless plans.include?(':')
    plans.split(',').map do |i|
      sub_array = i.split(':')
      [sub_array[0], sub_array[1].to_i]
    end.to_h
  end
end
