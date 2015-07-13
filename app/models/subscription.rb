class Subscription < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :plan

end
