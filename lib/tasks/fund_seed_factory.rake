namespace :fund do
  desc 'Seed fund data for development'
  task seed_factory: :environment do

    require 'factory_girl_rails'
    include FactoryGirl::Syntax::Methods

    Fund.destroy_all
    FundingType.where(label: 'Other').destroy_all
    Deadline.destroy_all
    Stage.destroy_all
    Outcome.destroy_all
    DecisionMaker.destroy_all

    FundingType.create(label: 'Other')

    @funder = Funder.find_by_name(['Lloyds Bank Foundation', 'Lloyds Bank Foundation England and Wales'])
    @funder.update_column(:name, 'Lloyds Bank Foundation England and Wales')
    @funds = build_list(:fund_with_open_data, 11, funder: @funder)

    @funds.each do |fund|
      fund.deadlines = create_list(:deadline, 2, fund: fund)
      fund.stages = create_list(:stage, 1, fund: fund)
      fund.funding_types = [FundingType.last]
      fund.countries = [Country.find_by_alpha2('GB')]
      fund.districts = Country.find_by_alpha2('GB').districts.take(3)
      fund.restrictions = Restriction.limit(2)
      fund.outcomes = create_list(:outcome, 2)
      fund.decision_makers = create_list(:decision_maker, 2)

      fund.save!
      print '.'
    end
    puts

    @funds.first.update_column(:name, 'Enable North')
    @funds.first.update_column(:slug, 'lloyds-bank-foundation-for-england-and-wales-enable-north')
    @funds.last.update_column(:name, 'Invest North')
    @funds.last.update_column(:slug, 'lloyds-bank-foundation-for-england-and-wales-invest-north')
  end
end
