# TODO: update
if Rails.env.development?
  require 'factory_girl_rails'
  require 'webmock'

  include FactoryGirl::Syntax::Methods
  include WebMock::API

  WebMock.enable!

  Implementation.destroy_all
  Implementation::IMPLEMENTATIONS.each do |hash|
    Implementation.create! hash
  end

  AgeGroup.destroy_all
  AgeGroup::AGE_GROUPS.each do |hash|
    AgeGroup.create! hash
  end

  Beneficiary.destroy_all
  Beneficiary::BENEFICIARIES.each do |hash|
    Beneficiary.create! hash
  end

  Country.destroy_all
  districts_csv = Rails.root.join('lib', 'assets', 'csv', 'districts.csv')
  array = []
  CSV.foreach(districts_csv, headers: true) do |row|
    array << row.to_hash
             .update(name: row['country'])
             .except('country', 'subdivision', 'district',
                     'label', 'region', 'sub_country')
  end
  array.uniq.each { |hash| Country.create! hash }

  District.destroy_all
  CSV.foreach(districts_csv, headers: true) do |row|
    data = row.to_hash
    data['country_id'] = Country.find_by(alpha2: row['alpha2']).id
    data = data.update(name: row['district'])
               .except('country', 'alpha2', 'district')
    District.create! data
  end

  Funder.destroy_all
  Fund.destroy_all
  Restriction.destroy_all
  require_relative '../spec/support/test_helper'
  app = TestHelper.new

  restrictions = create_list(:recipient_restriction, 2) +
                 create_list(:restriction, 3)
  funders = create_list(:funder, 20)
  funders.each do |funder|
    uk = Country.find_by(alpha2: 'GB')
    5.times do
      fund = build(:fund_with_open_data,
                   funder: funder,
                   countries: [uk],
                   districts: uk.districts.order('RANDOM()').limit(rand(1..10)),
                   restrictions: restrictions.take(rand(1..5)),
                   tags: Array.new(rand(1..5)) { |i| "Tag#{i + 1}" })
      app.stub_fund_summary_endpoint fund.instance_eval { set_slug }
      fund.save!
    end
  end
end
