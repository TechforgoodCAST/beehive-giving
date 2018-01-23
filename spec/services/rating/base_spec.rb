require 'rails_helper'

describe Rating::Base do
  subject { Class.new.include(Rating::Base).new(assessment: Assessment.new) }

  it '#assessment' do
    expect(subject.assessment).to be_an(Assessment)
  end

  it '#assessment is optional' do
    subject = Class.new.include(Rating::Base).new
    expect(subject.assessment).to eq(nil)
  end

  it '#colour' do
    expect { subject.colour }.to raise_error(NotImplementedError)
  end

  it('#message') { expect(subject.message).to eq('-') }

  it '#status' do
    expect { subject.status }.to raise_error(NotImplementedError)
  end

  it '#title' do
    expect { subject.title }.to raise_error(NotImplementedError)
  end
end
