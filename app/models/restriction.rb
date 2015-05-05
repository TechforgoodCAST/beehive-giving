class Restriction < ActiveRecord::Base
  belongs_to :funder

  validates :funder, :details, presence: true
end
