require 'rails_helper'
require 'pundit/rspec'

describe FundPolicy do
  subject { described_class }

  permissions :show? do
    before(:each) do
      @user = instance_double(User, subscribed?: false)
      @fund = instance_double(Fund, slug: 'fund')
      @proposal = Proposal.new
    end

    it 'denies access if no fund supplied' do
      is_expected.not_to permit(@user, FundContext.new(nil, @proposal))
    end

    it 'denies access if no proposal supplied' do
      is_expected.not_to permit(@user, FundContext.new(@fund, nil))
    end

    it 'grants access if user subscribed' do
      allow(@user).to receive(:subscribed?).and_return(true)
      is_expected.to permit(@user, FundContext.new(@fund, @proposal))
    end

    it 'grants access if fund recommended' do
      @proposal.suitability = { @fund.slug => { 'total' => 1 } }
      is_expected.to permit(@user, FundContext.new(@fund, @proposal))
    end

    it 'denies access if fund not recommended' do
      is_expected.not_to permit(@user, FundContext.new(@fund, @proposal))
    end
  end
end
