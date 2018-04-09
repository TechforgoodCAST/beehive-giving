require 'rails_helper'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'

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

  it { is_expected.to be_valid }

  it('#funding_type in list') { expect_invalid(:funding_type, '-1') }

  it('#country required') { expect_invalid(:country, nil) }

  it('#themes required') { expect_invalid(:themes, ['']) }

  it 'attributes cast to integer' do
    %i[funding_type org_type].each do |a|
      subject.send("#{a}=", '1')
      expect(subject.send(a)).to be_an(Integer)
    end
  end

  it 'attributes not cast to integer' do
    %i[funding_type org_type].each do |a|
      subject.send("#{a}=", nil)
      expect(subject.send(a)).to eq(nil)
    end
  end
end
