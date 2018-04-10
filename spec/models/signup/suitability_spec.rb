require 'rails_helper'

describe Signup::Suitability do
  subject do
    basics = Signup::Basics.new(
      country: 'GB',
      funding_type: FUNDING_TYPES[1][1], # Capital
      org_type: 0, # An unregistered organisation OR project
      themes: ['', '1']
    )
    described_class.new(basics)
  end

  it('cannot #initialize invalid object') { raise }
  it('#initialize Recipient') { raise }
  it('#initialize Proposal') { raise }
  it('#initialize User') { raise }
  it('#save when children valid') { raise }
  it('params update children') { raise }
end
