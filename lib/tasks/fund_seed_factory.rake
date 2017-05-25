namespace :fund do
  desc 'Seed fund data for development'
  task seed_factory: :environment do
    require 'factory_girl_rails'
    include FactoryGirl::Syntax::Methods

    Fund.destroy_all
    FundingType.where(label: 'Other').destroy_all
    Outcome.destroy_all
    DecisionMaker.destroy_all

    FundingType.create(label: 'Other')

    @funder = Funder.find_by(name: ['Lloyds Bank Foundation', 'Lloyds Bank Foundation for England and Wales'])
    @funder.update_column(:name, 'Lloyds Bank Foundation for England and Wales')
    @funder.update_column(:slug, 'lloyds-bank-foundation-for-england-and-wales')
    @funds = build_list(:fund_with_open_data, 11, funder: @funder)

    @funds.each do |fund|
      fund.funding_types = [FundingType.last]
      fund.countries = [Country.find_by(alpha2: 'GB')]
      fund.districts = Country.find_by(alpha2: 'GB').districts.take(3)
      fund.restrictions = Restriction.limit(2)
      fund.outcomes = create_list(:outcome, 2)
      fund.decision_makers = create_list(:decision_maker, 2)
      fund.tags += ['Arts']

      fund.save!
      print '.'
    end
    puts

    @funds.first.update_column(:name, 'Enable North')
    @funds.first.update_column(:slug, 'lloyds-bank-foundation-for-england-and-wales-enable-north')
    @funds.last.update_column(:name, 'Invest North')
    @funds.last.update_column(:slug, 'lloyds-bank-foundation-for-england-and-wales-invest-north')
  end

  task restrictions: :environment do
    funder = Funder.find_by(name: 'Lloyds Bank Foundation England and Wales')
    fund = funder.funds.first
    restrictions = funder.funding_streams.first.restrictions
    fund.restriction_ids = restrictions.pluck(:id)
    fund.save!
  end
end
