require 'rails_helper'
require 'pundit/rspec'

describe FundPolicy do
  subject { described_class }

  let(:version) { 1 }

  let(:subscribed) { false }
  let(:suitability) { {} }

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new(suitability: suitability) }
  let(:reveals) { [] }
  let(:user) do
    instance_double(
      User,
      subscription_active?: subscribed,
      subscription_version: version,
      reveals: reveals
    )
  end

  context 'v1' do
    permissions :show? do
      it 'denies access if no fund supplied' do
        is_expected.not_to permit(user, FundContext.new(nil, proposal))
      end

      it 'denies access if no proposal supplied' do
        is_expected.not_to permit(user, FundContext.new(fund, nil))
      end

      context 'user subscribed' do
        let(:subscribed) { true }

        it 'grants access' do
          is_expected.to permit(user, FundContext.new(fund, proposal))
        end
      end

      context 'fund recommended' do
        let(:suitability) { { fund.slug => { 'total' => 1 } } }

        it 'grants access' do
          is_expected.to permit(user, FundContext.new(fund, proposal))
        end
      end

      context 'fund not recommended' do
        it 'denies access' do
          is_expected.not_to permit(user, FundContext.new(fund, proposal))
        end
      end
    end
  end

  context 'v2' do
    let(:version) { 2 }

    permissions :show? do
      it 'denies access if no fund supplied' do
        is_expected.not_to permit(user, fund)
      end

      context 'user subscribed' do
        let(:subscribed) { true }

        it 'grants access' do
          is_expected.to permit(user, fund)
        end
      end

      context 'fund revealed' do
        let(:reveals) { [fund.slug] }

        it 'grants access' do
          is_expected.to permit(user, fund)
        end
      end

      context 'fund revealed and subscribed' do
        let(:subscribed) { true }
        let(:reveals) { [fund.slug] }

        it 'grants access' do
          is_expected.to permit(user, fund)
        end
      end

      context 'fund not revealed' do
        it 'denies access' do
          is_expected.not_to permit(user, fund)
        end
      end
    end
  end
end
