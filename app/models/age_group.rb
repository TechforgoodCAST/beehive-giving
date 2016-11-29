class AgeGroup < ActiveRecord::Base

  AGE_GROUPS = [
    { label: 'All ages',                    age_from: 0,  age_to: 150 },
    { label: 'Infants (0-3 years)',         age_from: 0,  age_to: 3   },
    { label: 'Children (4-11 years)',       age_from: 4,  age_to: 11  },
    { label: 'Adolescents (12-19 years)',   age_from: 12, age_to: 19  },
    { label: 'Young adults (20-35 years)',  age_from: 20, age_to: 35  },
    { label: 'Adults (36-50 years)',        age_from: 36, age_to: 50  },
    { label: 'Mature adults (51-80 years)', age_from: 51, age_to: 80  },
    { label: 'Older adults (80+)',          age_from: 80, age_to: 150 }
  ]

  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :profiles # TODO: deprecated

  validates :label, :age_from, :age_to, presence: true
  validates :label, uniqueness: true

end
