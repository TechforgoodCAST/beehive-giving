require 'rails_helper'

describe Rating::Eligibility::Quiz do
  subject { Rating::Eligibility::Quiz.new(1234, {}) }

  it '#link' do
    expect(subject.link).to eq("<a href='#1234'>Answers</a>")
  end
end
