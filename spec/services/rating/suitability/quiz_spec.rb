require 'rails_helper'

describe Rating::Suitability::Quiz do
  subject { Rating::Suitability::Quiz.new(1234, {}) }

  it '#link' do
    expect(subject.link).to eq("<a href='#1234'>Your answers</a>")
  end
end
