class Beneficiary < ActiveRecord::Base

  scope :people, -> { where(category: 'People') }
  scope :other,  -> { where(category: 'Other') }

  BENEFICIARIES = [
    {
      label: "The general public",
      category: "People",
      sort:  "public"
    },
    {
      label: "Affected or involved with crime",
      category: "People",
      sort:  "crime"
    },
    {
      label: "With family/relationship challenges",
      category: "People",
      sort:  "relationship"
    },
    {
      label: "With disabilities",
      category: "People",
      sort:  "disabilities"
    },
    {
      label: "With specific religious/spiritual beliefs",
      category: "People",
      sort:  "religious"
    },
    {
      label: "Affected by disasters",
      category: "People",
      sort:  "disasters"
    },
    {
      label: "In education",
      category: "People",
      sort:  "education"
    },
    {
      label: "Who are unemployed",
      category: "People",
      sort:  "unemployed"
    },
    {
      label: "From a specific ethnic background",
      category: "People",
      sort:  "ethnic"
    },
    {
      label: "With water/sanitation access challenges",
      category: "People",
      sort:  "water"
    },
    {
      label: "With food access challenges",
      category: "People",
      sort:  "food"
    },
    {
      label: "With housing/shelter challenges",
      category: "People",
      sort:  "housing"
    },
    {
      label: "Animals and wildlife",
      category: "Other",
      sort:  "animals"
    },
    {
      label: "Buildings and places",
      category: "Other",
      sort:  "buildings"
    },
    {
      label: "With mental diseases or disorders",
      category: "People",
      sort:  "mental"
    },
    {
      label: "With a specific sexual orientation",
      category: "People",
      sort:  "orientation"
    },
    {
      label: "Climate and the environment",
      category: "Other",
      sort:  "environment"
    },
    {
      label: "With physical diseases or disorders",
      category: "People",
      sort:  "physical"
    },
    {
      label: "This organisation",
      category: "Other",
      sort:  "organisation"
    },
    {
      label: "Other organisations",
      category: "Other",
      sort:  "organisations"
    },
    {
      label: "Facing income poverty",
      category: "People",
      sort:  "poverty"
    },
    {
      label: "Who are refugees and asylum seekers",
      category: "People",
      sort:  "refugees"
    },
    {
      label: "Involved with the armed or rescue services",
      category: "People",
      sort:  "services"
    },
    {
      label: "In, leaving, or providing care",
      category: "People",
      sort:  "care"
    },
    {
      label: "At risk of sexual exploitation, trafficking, forced labour, or servitude",
      category: "People",
      sort:  "exploitation"
    }
  ]

  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :proposals

  validates :label, :sort, :category, presence: true
  validates :label, :sort, uniqueness: true

end
