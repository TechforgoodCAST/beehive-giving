require 'rails_helper'

describe Vote do
  subject { build(:vote) }

  it('belongs to Assessment') { assoc(:assessment, :belongs_to) }

  it { is_expected.to be_valid }

  it 'agree with rating' do
    subject = build(:vote_agree)
    is_expected.to be_valid
  end

  it '#relationship_to_assessment presence' do
    subject.update(relationship_to_assessment: nil)
    expect_error(:relationship_to_assessment, "can't be blank")
  end

  it "#relationship_details required if 'Another role'" do
    subject.update(relationship_details: nil)
    expect_error(:relationship_details, "can't be blank")
  end

  it '#agree_with_rating inclusion' do
    subject.update(agree_with_rating: nil)
    expect_error(:agree_with_rating, 'is not included in the list')
  end

  it '#reason required if disagree with rating' do
    subject.update(reason: nil)
    expect_error(:reason, "can't be blank")
  end
end
