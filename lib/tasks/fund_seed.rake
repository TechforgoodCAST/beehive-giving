namespace :fund do
  desc 'Seed fund data for development'
  task seed: :environment do

    Fund.destroy_all
    Outcome.destroy_all
    FundingType.where(label: 'Other').destroy_all

    # Without historic analysis
    fund1 = Fund.new(
      funder: Funder.find_by_name('Arts Council England'),
      type_of_fund: 'Grant',
      funding_types: [FundingType.create(label: 'Other')],
      name: 'Ambition for Excellence',
      year_of_fund: 2016,
      description:
        "Funding to support organisations and partnerships, including private "\
        "sector arts companies, community and charitable arts organisations, "\
        "museums with production, commissioning or creative projects that have "\
        "potential for significant impact on the development of talent and "\
        "leadership, and the growth of an ambitious international-facing arts "\
        "infrastructure in England, especially outside London.",
      open_call: true,
      active: true,
      currency: 'GBP',
      amount_known: true,
      amount_min_limited: true,
      amount_max_limited: true,
      amount_min: 100000,
      amount_max: 750000,
      duration_months_known: true,
      duration_months_min_limited: false,
      duration_months_max_limited: true,
      duration_months_max: 36,
      deadlines_known: true,
      deadlines_limited: true,
      stages_known: true,
      match_funding_restrictions:
        "A minimum of 10% the total cash cost of the activity must come from "\
        "sources other than the Arts Council. This can include funders overseas. "\
        "This match funding must be in cash, rather than in-kind.",
      accepts_calls_known: true,
      accepts_calls: true,
      contact_number: '08453006200',
      contact_email: 'enquiries@artscouncil.org.uk',
      geographic_scale: 0,
      geographic_scale_limited: true,
      countries: Country.where(alpha2: 'GB'),
      districts: District.where(district: 'Birmingham'),
      restrictions_known: true,
      restrictions: [Restriction.first],
      outcomes_known: true,
      outcomes: [
        Outcome.create(outcome: 'Contribute to the development of strong cultural places.')
      ],
      documents_known: false,
      decision_makers_known: false
    )

    fund1.deadlines.build(deadline: Time.new(2017,10,27,17,00,00))
    fund1.stages.build(name: 'Speak with member of staff', position: 1, feedback_provided: false)
    fund1.stages.build(name: 'Expression of interest', position: 2, feedback_provided: false)
    fund1.save!

    # With historic analysis
    fund2 = Fund.new(
      funder: Funder.find_by_name('Oxfordshire Community Foundation'),
      type_of_fund: 'Grant',
      funding_types: [FundingType.last],
      name: 'Community Grant General Fund',
      year_of_fund: 2016,
      description:
        "Grants are available to groups and projects working to tackle "\
        "disadvantage and improve the quality of life of people in Oxfordshire.",
      open_call: true,
      active: true,
      currency: 'GBP',
      amount_known: true,
      amount_min_limited: true,
      amount_max_limited: true,
      amount_min: 500,
      amount_max: 5000,
      duration_months_known: false,
      deadlines_known: true,
      deadlines_limited: true,
      stages_known: false,
      accepts_calls_known: false,
      contact_number: '01865798666',
      contact_email: 'ocf@oxfordshire.org',
      geographic_scale: 1,
      geographic_scale_limited: true,
      countries: Country.where(alpha2: 'GB'),
      districts: District.where(district:
        ['Oxford', 'Cherwell', 'South Oxfordshire', 'Vale of White Horse', 'West Oxfordshire']
      ),
      restrictions_known: true,
      restrictions: [Restriction.first],
      outcomes_known: false,
      documents_known: false,
      decision_makers_known: false
    )

    fund2.deadlines.build(deadline: Time.new(2016,10,28,00,00,00))
    fund2.save!

  end
end
