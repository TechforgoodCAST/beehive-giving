require 'rails_helper'
require 'shared/org_type_validations'
require 'shared/reg_no_validations'
require 'shared/setter_to_integer'

describe Signup::Basics do
  subject do
    described_class.new(
      country: 'GB',
      funding_type: FUNDING_TYPES[1][1], # Capital
      org_type: 0, # An unregistered organisation OR project
      themes: ['', '1']
    )
  end

  def expect_invalid(attribute, value)
    subject.send("#{attribute}=", value)
    subject.valid?
    expect(subject.errors.messages).to have_key(attribute)
  end

  include_examples 'org_type validations'
  include_examples 'reg no validations'
  include_examples 'setter to integer' do
    let(:attributes) { %i[funding_type org_type] }
  end

  it { is_expected.to be_valid }

  it('#funding_type in list') { expect_invalid(:funding_type, '-1') }

  it('#country required') { expect_invalid(:country, nil) }

  it('#themes required') { expect_invalid(:themes, ['']) }

  it '#proposal returns correct attributes' do
    keys = %i[funding_type themes]
    expect(subject.proposal).to include(*keys)
  end

  it '#recipient returns correct attributes' do
    keys = %i[charity_number company_number country org_type]
    expect(subject.recipient).to include(*keys)
  end

  it '#attributes returns all attributes' do
    keys = subject.proposal.merge(subject.recipient)
    expect(subject.attributes).to include(keys)
  end
end
