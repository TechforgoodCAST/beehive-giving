require 'rails_helper'
require 'pundit/rspec'

describe FundPolicy do
  subject { described_class }

  let(:subscribed) { false }
  let(:fund) { build(:fund) }
  let(:reveals) { [] }
  let(:user) do
    instance_double(User, subscription_active?: subscribed, reveals: reveals)
  end
  let(:context) { FundContext.new(fund, build(:proposal)) }

  permissions :show? do
    it 'denies access if no fund supplied' do
      is_expected.not_to permit(user, context)
    end

    context 'user subscribed' do
      let(:subscribed) { true }
      it { is_expected.to permit(user, context) }
    end

    context 'fund revealed' do
      let(:reveals) { [fund.slug] }
      it { is_expected.to permit(user, context) }
    end

    context 'fund revealed and subscribed' do
      let(:subscribed) { true }
      let(:reveals) { [fund.slug] }
      it { is_expected.to permit(user, context) }
    end

    context 'fund not revealed' do
      it { is_expected.not_to permit(user, context) }
    end
  end
end
