require 'rails_helper'

describe CompaniesHouse do
  let(:helper) { MatchHelper.new }

  before(:each) do
    helper.stub_companies_house
          .stub_companies_house(number: 'missing', content_type: 'text/html')
          .stub_companies_house(
            file: 'companies_house_partial_stub.json', number: 'partial'
          )
  end

  it 'requires company_number to initialize' do
    expect { CompaniesHouse.new }.to raise_error(ArgumentError)
  end

  it '#lookup requires Organisation instance' do
    expect { CompaniesHouse.new('09544506').lookup }
      .to raise_error(ArgumentError)
  end

  it '#lookup returns false unless JSON' do
    expect(CompaniesHouse.new('missing').lookup({})).to eq false
  end

  it '#lookup for partial record' do
    org = Recipient.new
    CompaniesHouse.new('partial').lookup(org)
    expect(org.name).to eq 'Partial Response'
  end

  it '#lookup for replaces org.name if org.charity_number.present?' do
    org = create(:recipient)
    CompaniesHouse.new('09544506').lookup(org)
    expect(org.name).to eq 'ACME'
  end

  it '#lookup for full record' do
    org = Recipient.new
    CompaniesHouse.new('09544506').lookup(org)
    expect(org.name).to eq 'Centre For The Acceleration Of Social Technology'
    expect(org.country).to eq 'GB'
  end

  it '#operating_for_value' do
    [1, 2, 3].each do |years_old|
      expect(
        CompaniesHouse.new('09544506').instance_eval do
          operating_for_value(years_old.send(:years).ago)
        end
      ).to eq years_old
    end
  end
end
