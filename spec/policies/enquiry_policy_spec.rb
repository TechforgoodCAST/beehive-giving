require 'rails_helper'
require 'pundit/rspec'

describe EnquiryPolicy do
  subject { described_class }

  let(:version) { 1 }

  let(:subscribed) { false }
  let(:eligibility) { {} }
  let(:suitability) { {} }

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) do
    Proposal.new(eligibility: eligibility, suitability: suitability)
  end
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
    permissions :new?, :create? do
      context 'eligible' do
        let(:eligibility) do
          { fund.slug => { 'quiz' => { 'eligible' => true } } }
        end

        it 'fund not recommended denies access' do
          is_expected.not_to permit(user, EnquiryContext.new(fund, proposal))
        end

        context 'fund recommended' do
          let(:suitability) { { fund.slug => { 'total' => 1 } } }

          it 'grants access' do
            is_expected.to permit(user, EnquiryContext.new(fund, proposal))
          end
        end
      end

      it 'ineligible denies access' do
        is_expected.not_to permit(user, EnquiryContext.new(fund, proposal))
      end

      context 'user subscribed' do
        let(:subscribed) { true }

        it 'grants access' do
          is_expected.to permit(user, EnquiryContext.new(fund, proposal))
        end
      end
    end
  end

  context 'v2' do
    let(:version) { 2 }

    permissions :new?, :create? do
      it 'denies access if no fund supplied' do
        is_expected.not_to permit(user, EnquiryContext.new(fund, proposal))
      end

      context 'user subscribed' do
        let(:subscribed) { true }

        it 'grants access' do
          is_expected.to permit(user, EnquiryContext.new(fund, proposal))
        end
      end

      context 'fund revealed' do
        let(:reveals) { [fund.slug] }

        it 'grants access' do
          is_expected.to permit(user, EnquiryContext.new(fund, proposal))
        end
      end

      context 'fund revealed and subscribed' do
        let(:subscribed) { true }
        let(:reveals) { [fund.slug] }

        it 'grants access' do
          is_expected.to permit(user, EnquiryContext.new(fund, proposal))
        end
      end

      context 'fund not revealed' do
        it 'denies access' do
          is_expected.not_to permit(user, EnquiryContext.new(fund, proposal))
        end
      end
    end
  end
end
