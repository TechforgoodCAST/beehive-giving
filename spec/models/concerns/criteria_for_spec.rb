require 'rails_helper'

describe CriteriaFor do
  before do
    %w[Recipient Proposal].each do |category|
      %w[Restriction Priority].each do |type|
        create(:restriction, category: category, type: type)
      end
    end
  end

  subject do
    class Collection
      include CriteriaFor
      attr_accessor :restrictions, :priorities
    end
    collection = Collection.new
    collection.restrictions = Restriction.all
    collection.priorities = Priority.all
    collection
  end

  it 'returns recipient restrictions' do
    criteria = subject.criteria_for(:recipient, :restrictions)
    expect_criteria(criteria, 'Recipient', 'Restriction')
  end

  it 'returns recipient priorities' do
    criteria = subject.criteria_for(:recipient, :priorities)
    expect_criteria(criteria, 'Recipient', 'Priority')
  end

  it 'returns proposal restrictions' do
    criteria = subject.criteria_for(:proposal, :restrictions)
    expect_criteria(criteria, 'Proposal', 'Restriction')
  end

  it 'returns proposal priorities' do
    criteria = subject.criteria_for(:proposal, :priorities)
    expect_criteria(criteria, 'Proposal', 'Priority')
  end
end

def expect_criteria(criteria, category, type)
  criteria.each do |criterion|
    expect(criterion).to have_attributes(category: category, type: type)
  end
end
