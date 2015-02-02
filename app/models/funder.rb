class Funder < Organisation
  has_many :grants
  has_many :features
end
