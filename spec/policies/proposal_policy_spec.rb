require 'pundit/rspec'

describe ProposalPolicy do
  subject { described_class }

  before(:each) do
    @user = instance_double(User, subscription_active?: false)
    @proposal = Proposal.new
  end

  permissions :new?, :create? do
    it 'denies access if user unsubscribed' do
      is_expected.not_to permit(@user, @proposal)
    end

    it 'grants access if user subscribed' do
      allow(@user).to receive(:subscription_active?).and_return(true)
      is_expected.to permit(@user, @proposal)
    end
  end
end
