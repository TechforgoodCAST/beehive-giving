require 'rails_helper'
require 'support/match_helper'
require 'shared/recipient_validations'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'

describe Recipient do
  subject { build(:recipient) }

  include_examples 'recipient validations'
  include_examples 'reg no validations'
  include_examples 'org_type validations'

  it('has many Answers') { assoc(:answers, :has_many, dependent: :destroy) }

  it('has many Attempts') { assoc(:attempts, :has_many) }

  it('has many Assessments') { assoc(:assessments, :has_many) }

  it('has many Countries') { assoc(:countries, :has_many, through: :proposals) }

  it('has many Districts') { assoc(:districts, :has_many, through: :proposals) }

  it('has many Proposals') { assoc(:proposals, :has_many) }

  it 'has one Subscription' do
    assoc(:subscription, :has_one, dependent: :destroy)
  end

  it('has many Requests') { assoc(:requests, :has_many) }

  it('has many Users') { assoc(:users, :has_many, dependent: :destroy) }

  it { is_expected.to be_valid }

  it 'website invalid' do
    subject.website = 'www.example.com'
    expect(subject).not_to be_valid
  end

  it 'website valid' do
    subject.website = 'https://www.example.com'
    expect(subject).to be_valid
  end

  it 'reveals has unique fund slugs' do
    subject.update(reveals: %w[fund-slug-1 fund-slug-1])
    expect(subject.reveals).to eq ['fund-slug-1']
  end

  it 'strips whitespace' do
    %i[charity_number company_number].each do |field|
      subject.update("#{field}": ' with whitespace ')
      expect(subject[field]).to eq 'with whitespace'
    end
  end

  it 'geocoded by street address and country if no postal code' do
    subject.update(street_address: 'London Road')
    expect(subject.postal_code).to be_nil
    expect(subject.latitude).to eq 1.0
    expect(subject.longitude).to eq 1.0
  end

  it 'only geocode for GB' do
    subject.update(street_address: 'London Road', country: 'KE')
    expect(subject.latitude).to be_nil
    expect(subject.longitude).to be_nil
  end

  it 'geocoded by postal code' do
    subject.update(postal_code: 'POSTCODE')
    expect(subject.latitude).to eq 0.0
    expect(subject.longitude).to eq 0.0
  end

  it 'reg nos cleared if unregistered' do
    subject.update(org_type: 0)
    expect(subject.charity_number).to be_nil
    expect(subject.company_number).to be_nil
  end

  it 'updates slug if name changed' do
    subject.update(name: 'New Name!')
    expect(subject.slug).to eq 'new-name'
  end

  context 'persisted' do
    before { subject.save }

    it 'has slug' do
      expect(subject.slug).to eq 'acme'
    end

    it 'slug is unique' do
      expect(create(:recipient, name: 'ACME').slug).to eq 'acme-2'
    end

    it 'updates slug if name present' do
      subject.update(name: '')
      expect(subject.slug).to eq 'acme'
    end
  end

  it 'methods e.g. #scrape_org, #find_with_reg_nos, etc.'
end
