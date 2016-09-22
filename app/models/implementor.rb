class Implementor < ActiveRecord::Base
  has_and_belongs_to_many :profiles # TODO: deprecated
end
