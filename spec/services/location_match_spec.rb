require 'rails_helper'

fdescribe LocationMatch do
  it 'requires funds and proposal to initialize'

  context 'fund seeking work in other countries' do
    it 'fund ineligible for proposal does not match countries'
  end

  context 'fund seeking work at national scale' do
    it 'fund eligible for proposal seeking funding at national level'
    it 'fund ineligible for proposal seeking funding at national level'
  end

  context 'fund seeking work at a local level' do
    it 'fund neutral with notice for national proposal'
    it 'fund ineligible with notice for local proposal no district match'
    it 'fund eligible with notice for local proposal partial/full match'
    it 'fund neutral with notice for local proposal intersect/overlap match'
  end

  context 'fund seeking work at any level' do
    it 'fund eligible with notice for local proposal'
    it 'fund eligible with notice for national proposal'
  end
end
