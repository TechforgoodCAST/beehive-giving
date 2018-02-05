require 'rails_helper'

describe Check::Base do
  subject { Class.new.include(Check::Base).new }

  it '#call assigns #assessment' do
    subject.call(Assessment.new)
    expect(subject.assessment).to be_a(Assessment)
  end

  it '#call raise invalid Assessment' do
    expect { subject.call({}) }
      .to raise_error(ArgumentError, 'Invalid Assessment')
  end
end
