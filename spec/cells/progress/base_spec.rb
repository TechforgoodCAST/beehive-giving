require 'rails_helper'

describe Progress::Base do
  it '#label' do
    expect { subject.label }.to raise_error(NotImplementedError)
  end

  it '#indicator' do
    expect { subject.indicator }.to raise_error(NotImplementedError)
  end

  it '#message' do
    expect { subject.message }.to raise_error(NotImplementedError)
  end

  it '#highlight' do
    expect { subject.highlight }.to raise_error(NotImplementedError)
  end
end
